import argparse
import string
import threading

import io
from PIL import Image

# import some common libraries
import torch
import numpy as np
import cv2
import os
import json

# import some detectron2 utilities
import detectron2
from detectron2 import model_zoo
from detectron2.config import get_cfg
from detectron2.data import DatasetCatalog, MetadataCatalog
from detectron2.engine import DefaultPredictor


annotation_type = "staves"


def prepare_cfg_variables(models_dir, model, category):
    model_dir = os.path.join(models_dir, model + "-" + category)
    cfg_file = "COCO-Detection/faster_rcnn_" + model + ".yaml"
    weight_file = os.path.join(model_dir, "last_checkpoint")
    last_checkpoint = open(weight_file, "r").read()
    path_to_weight_file = os.path.join(model_dir, last_checkpoint)
    return cfg_file, path_to_weight_file     


def setup_cfg(num_classes, cfg_file, existing_model_weight_path):
    cfg = get_cfg()
    cfg.merge_from_file(model_zoo.get_config_file(cfg_file))
    
    cfg.MODEL.WEIGHTS = existing_model_weight_path
    if not torch.cuda.is_available():
        cfg.MODEL.DEVICE = "cpu"
    cfg.MODEL.ROI_HEADS.NUM_CLASSES = num_classes
    # set the testing threshold for this model. Model should be at least 20% confident detection is correct
    cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.2
    cfg.MODEL.RETINANET.SCORE_THRESH_TEST = 0.2

    return cfg


def generate_predictions_as_json(input_images, predictor, annotation_type, out_path):
    json_out = []
    for img_file in input_images:
        json_out.append(generate_JSON_single_category(Image.open(img_file).convert("RGB"), predictor, annotation_type))
        print("Processed '" + img_file + "'.")

    with open(out_path, "w", encoding="utf8") as outfile:
        json.dump(json_out, outfile, indent=4, ensure_ascii=False)


def generate_JSON_single_category(image, predictor, annotation_type):
    im = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)
    outputs = predictor(im)
    all_boxes = outputs["instances"].pred_boxes.tensor.cpu().numpy() # left, top, right, bottom
    json_dict = {}
    json_dict["width"] = image.width
    json_dict["height"] = image.height

    measures = []
    for box in all_boxes:
        annotation = {}
        annotation["left"] = int(box[0].item())
        annotation["top"] = int(box[1].item())
        annotation["right"] = int(box[2].item())
        annotation["bottom"] = int(box[3].item())
        measures.append(annotation)

    json_dict[annotation_type] = measures

    return json_dict


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Performs detection over input folder or image file with a trained detector.')
    parser.add_argument('input_images', type=str, nargs="*",
                        help='Path to the input image.')
    parser.add_argument('--models-dir', type=str, required=True,
                        help='Path to the trained network.')
    parser.add_argument('--model-type', type=str, default="R_50_FPN_3x",
                        help='Modeltype of trained network.')
    parser.add_argument('-o', '--out-path', type=str, default="/dev/stdout",
                        help='Output path.')
    args = parser.parse_args()

    input_path = args.input_images
    root_dir = args.models_dir
    model = args.model_type
    out_path = args.out_path

    def threadFunc():
        generate_predictions_as_json(input_path, predictor, annotation_type, out_path)
        print() # In the case out_path=/dev/stdout
        print("Done.")

    cfg_file, path_to_weight_file = prepare_cfg_variables(root_dir, model, annotation_type)
    cfg = setup_cfg(1, cfg_file, path_to_weight_file)
    predictor = DefaultPredictor(cfg)
    th = threading.Thread(target=threadFunc)
    th.start()
    th.join()
