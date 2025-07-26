import os

src = "./lib"
promptFileName = "prompt.txt"


if os.path.exists(promptFileName):
    os.remove(promptFileName)

def makeFile(path):
    files = os.listdir(path)
    for file in files:
        if file.endswith(".dart"):
            with open(os.path.join(path, file), "r") as f:
                content = f.read()
                with open(promptFileName, "a") as promptFile:
                    # Appends the content of the file to the prompt file
                    promptFile.write(path + "\n")
                    promptFile.write(content + "\n\n")
        else:
            makeFile(os.path.join(path, file))
                    

makeFile(src)
