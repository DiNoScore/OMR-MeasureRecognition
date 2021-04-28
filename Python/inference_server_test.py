import requests
import json
from PIL import Image
import io

# Upload some garbage
assert requests.post('http://localhost:8000/upload', files=[('file', open('README.md', 'rb'))]).status_code == 400

# Upload a too large file
assert requests.post('http://localhost:8000/upload', files=[('file', open('example-images/p001.png', 'rb'))]).status_code == 413

# Upload multiple files and it should work
files = []
for x in range(1, 21):
    image = Image.open('example-images/p' + str(x).zfill(3) + '.png')
    image.thumbnail([1024, 1024], Image.ANTIALIAS)

    byteIO = io.BytesIO()
    image.save(byteIO, format='PNG')

    files.append(('file', byteIO.getvalue() ))

# Test infer some images
with open("output.json", "w", encoding="utf8") as outfile:
    response = requests.post('http://localhost:8000/upload', files=files)
    print(response)
    print(response.content.decode())
    assert response.status_code == 200
    # The first page has 6 staves
    print(len(response.json()[0]['staves']))
    assert len(response.json()[0]['staves']) == 6

print("Test passed")
