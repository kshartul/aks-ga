FROM python:3.9.0

WORKDIR /build

COPY requirements.txt .

COPY  . .

RUN pip3 install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org -r requirements.txt

EXPOSE 5000

CMD [ "python", "app.py" ]