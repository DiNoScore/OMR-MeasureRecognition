import typing
import string
import concurrent
import flask
from flask import request

import io
from PIL import Image, UnidentifiedImageError

# import some common libraries
import os

# import some detectron2 utilities
import detectron2
from detectron2 import model_zoo
from detectron2.config import get_cfg
from detectron2.data import DatasetCatalog, MetadataCatalog
from detectron2.engine import DefaultPredictor

import inference_cli


from flask import Flask, Request


app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 8 * 1024 * 1024
app.config['JSON_AS_ASCII'] = False

@app.before_first_request
def init():
    global annotation_type, predictor
    annotation_type = "staves"
    models_dir = os.environ['MODELS_DIR']

    cfg_file, path_to_weight_file = inference_cli.prepare_cfg_variables(models_dir, "R_50_FPN_3x", annotation_type)
    cfg = inference_cli.setup_cfg(1, cfg_file, path_to_weight_file)
    predictor = DefaultPredictor(cfg)

    return app


def generate_predictions_as_json(files, predictor, annotation_type) -> typing.Tuple[typing.Any, int]:
    json_out = []
    for index, img_file in enumerate(files):
        try:
            image = Image.open(img_file.stream).convert("RGB")
            if image.width > 2048 or image.height > 2048:
                return f"Maximum allowed image size is 2048×2048, but image #{index} has size {image.width}×{image.height}. We recommend scaling down to a width of 800 pixels", 413
            json_out.append(inference_cli.generate_JSON_single_category(image, predictor, annotation_type))
        except UnidentifiedImageError:
            return f"File #{index} does not seem to be an image.", 400
    return flask.json.jsonify(json_out)

@app.route('/upload', methods=['GET', 'POST'])
def detect_measures():
    if request.method == 'POST':
        files = request.files.getlist("file")

        if len(files) > 50:
            return "Maximum of 50 files allowed per request", 413
        if len(files) == 0:
            return "Must provide at least one file", 400

        return generate_predictions_as_json(files, predictor, annotation_type)
    else:
        return "Yes, that's the correct URL! You need to POST-upload some images here to get your response (use a multipart entry like `Content-Disposition: form-data; name=\"file\"; filename=\"file\"` for this)"
