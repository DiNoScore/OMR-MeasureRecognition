import requests
import json
from PIL import Image
import io

url = 'http://localhost:8000/upload'


# Upload some garbage
status_code = requests.post(url, files=[('file', open('README.md', 'rb'))]).status_code
assert status_code == 400, "Status code was " + str(status_code)
print("Test 1 passed")

# Upload a too large file
assert requests.post(url, files=[('file', open('example-images/p001.png', 'rb'))]).status_code == 413
print("Test 2 passed")

# Upload multiple files and it should work
files = []
for x in range(1, 21):
    image = Image.open('example-images/p' + str(x).zfill(3) + '.png')
    image.thumbnail([1024, 1024], Image.LANCZOS)

    byteIO = io.BytesIO()
    image.save(byteIO, format='PNG')

    files.append(('file', byteIO.getvalue() ))

# Test infer some images
response = requests.post(url, files=files)
print(response)
print(response.content.decode())
assert response.status_code == 200
# The first page has 6 staves
print(len(response.json()[0]['staves']))
assert len(response.json()[0]['staves']) == 6
print("Test 3 passed")
