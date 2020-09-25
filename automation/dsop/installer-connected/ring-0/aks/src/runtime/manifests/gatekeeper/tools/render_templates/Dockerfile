FROM python:3.8

WORKDIR /src/runtime/manifests/gatekeeper/tools/render_templates

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "python", "./render_templates.py" ]