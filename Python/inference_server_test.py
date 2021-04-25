import requests
import json

files = {}
for x in range(1, 21):
    files.update({'p' + str(x).zfill(3) : open('images/p' + str(x).zfill(3) + '.png', 'rb')})
files.update({'photo.jpg' : open('images/photo.jpg', 'rb')})

with open("output.json", "w", encoding="utf8") as outfile:
    json.dump(requests.post('http://localhost:8000/upload?root_dir=./../Models', files=files).json(), outfile, indent=4, ensure_ascii=False)
