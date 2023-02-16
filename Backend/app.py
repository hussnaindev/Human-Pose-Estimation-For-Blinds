from flask import Flask, request, jsonify
from matplotlib import pyplot as plt
from gluoncv import model_zoo, data, utils
from gluoncv.data.transforms.pose import detector_to_alpha_pose, heatmap_to_coord_alpha_pose
# import cv2
# from torchvision import models
# from torchvision.models.detection.keypoint_rcnn import keypointrcnn_resnet50_fpn
# import torch
# import numpy as np
# import posenet
# import tensorflow as tf
# from tensorflow import keras 

app = Flask(__name__)

@app.route("/predict")
def predict():
   
    detector = model_zoo.get_model('yolo3_mobilenet1.0_coco', pretrained=True)
    pose_net = model_zoo.get_model('alpha_pose_resnet101_v1b_coco', pretrained=True)

    # Note that we can reset the classes of the detector to only include
    # human, so that the NMS process is faster.

    detector.reset_class(["person"], reuse_weights=['person'])
    im_fname = utils.download('https://github.com/dmlc/web-data/blob/master/' +
                            'gluoncv/pose/soccer.png?raw=true',
                            path='soccer.png')
    x, img = data.transforms.presets.yolo.load_test(im_fname, short=512)
    print('Shape of pre-processed image:', x.shape)

    class_IDs, scores, bounding_boxs = detector(x)
    pose_input, upscale_bbox = detector_to_alpha_pose(img, class_IDs, scores, bounding_boxs)
    pose_input
    predicted_heatmap = pose_net(pose_input)
    pred_coords, confidence = heatmap_to_coord_alpha_pose(predicted_heatmap, upscale_bbox)
    pred_coords
    ax = utils.viz.plot_keypoints(img, pred_coords, confidence,
                                class_IDs, bounding_boxs, scores,
                                box_thresh=0.5, keypoint_thresh=0.2)
    plt.show()
    # # Get the image from the request
    # # image = request.files["image"].read()
    # print(tf.__version__)
    # image = cv2.imread("imgg.jpg")
    # init = tf.compat.v1.global_variables_initializer()
    # with tf.compat.v1.Session() as sess:
    #     sess.run(init)
    #     model = posenet.load_model(101,sess)
    #     print(model)
    # # Preprocess the image
    # # image = cv2.resize(image, (224, 224))
    # # image = image.transpose((2, 0, 1))
    # # image = image.reshape(1, 3, 224, 224)
    # # image = torch.from_numpy(image)
    # # image = image.float()
    # # # # Pass the image through the model
    # # # model = keypointrcnn_resnet50_fpn(pretrained=True,num_keypoints=17, pretrained_backbone=False)
    # # model = pose_resnet50_fp16(pretrained=True, pretrained_backbone=False)
    # # model.eval()
    # # output = model(image)
    # # keypoints = output[0]["keypoints"]
    # # print(keypoints)
    # # print(models)
    # # # Convert the keypoints to a JSON format
    # # keypoints = keypoints.detach().cpu().numpy().tolist()
    # # keypoints = {"keypoints": keypoints}
    # # return jsonify(keypoints)
    return "sahi chal raha hai"

if __name__ == "__main__":
    app.run(debug=True)
