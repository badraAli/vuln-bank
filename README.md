- Clone this project
- Go into the cloned project directory
- Make sure you have Docker installed on your machine
- Run the following commands:
- "sudo docker build -t vuln-bank ."
- "sudo docker run -p 5000:5000 vuln-bank"
- Don't run these commands with the quotation marks
- Visit http://172.17.0.2:5000/ to start testing

Pour lancer localement

docker build -t vulnerable-app .
docker image ls > vulnerable-app                 latest    5d202f3e2f00   4 minutes ago   256MB
docker run -t -d -p 5557:5000 --name vulnapp vulnerable-app:latest > f40caefa7b45   vulnerable-app:latest   "python app.py"   2 minutes ago   Up 2 minutes    0.0.0.0:5557->5000/tcp   vulnapp
