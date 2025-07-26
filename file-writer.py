import json


with open("data.json", "r") as f:
    data = json.load(f)
    
    for item in data:
        filePath = item["filePath"]
        fileContent = item["fileContent"]
        
        with open(filePath, "w") as file:
            file.write(fileContent) 