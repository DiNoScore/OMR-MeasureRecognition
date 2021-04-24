import argparse
import string
import concurrent
import hug

import io
from PIL import Image

# import some common libraries
import torch
import numpy as np
import cv2
import os

# import some detectron2 utilities
import detectron2
from detectron2 import model_zoo
from detectron2.config import get_cfg
from detectron2.data import DatasetCatalog, MetadataCatalog
from detectron2.engine import DefaultPredictor


type_of_annotation = "staves"
       
def prepare_cfg_variables(root_dir, model, category):
    model_dir = os.path.join(root_dir, model + "-" + category)
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
    
def generate_predictions_as_json(img_file_buffer, predictor, type_of_annotation):
    json_out = {}
    for img_name, img_file in img_file_buffer.items():
        json_dict = []
        json_dict.append(generate_JSON_single_category(img_file, predictor, type_of_annotation))
        json_out[img_name] = json_dict
        print(img_name + " done.")
    print("Done")
    return json_out


def generate_JSON_single_category(img_file, predictor, annotation_type):
    image = Image.open(io.BytesIO(img_file)).convert("RGB")
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

@hug.post('/upload')
def detect_measures(body, root_dir):
    """runs inference on images"""
    output = {}
    cfg_file, path_to_weight_file = prepare_cfg_variables(root_dir, "R_50_FPN_3x", type_of_annotation)
    cfg = setup_cfg(1, cfg_file, path_to_weight_file)
    predictor = DefaultPredictor(cfg)
    def threadFunc():
        return generate_predictions_as_json(body, predictor, type_of_annotation)
    with concurrent.futures.ThreadPoolExecutor() as executor:
        future = executor.submit(threadFunc)
        output = future.result()
    return output
