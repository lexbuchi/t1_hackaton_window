# Запускаем из /embeddings_model
#не забыть показать как качать модель в папку и откуда чтобы все запустилось
#сервим эмбеддинги на fastapi
docker build -t USER-bge-m3-server .
docker run --name --detach USER-bge-m3-server -p 8000:8000 --runtime nvidia --gpus device=1 USER-bge-m3-server

#Важно!! OpenAI key нигде не изменять, vllm это не нужно (запускаем модельки локально)


#Запуск neo4j. После этого необходимо перейти в интерфейс neo4j по адресу http://0.0.0.0:7474/browser/, залогиниться (логин и пароль указаны в аргументах) и создать базу знаний с помощью команды "CREATE DATABASE hackaton"
docker run -d --publish=7474:7474 --publish=7687:7687 \
    --name appliner-knowledge-base \
    -v $HOME/kg/data:/data \
    -v $HOME/kg/logs:/logs \
    -v $HOME/kg/import:/var/lib/neo4j/import \
    -v $HOME/kg/plugins:/plugins \
    --env NEO4J_AUTH=neo4j/password \
    --env NEO4J_PLUGINS='["apoc"]' \
    --env NEO4J_apoc_export_file_enabled=true \
    --env NEO4J_apoc_import_file_enabled=true \
    --env NEO4J_dbms_security_procedures_unrestricted='*' \
    nexus.appl.local:5090/graphstack/dozerdb:5.22.0.0-alpha.1

## Запуск 7b модели Vikhrmodels_Vikhr-Llama3.1-8B-Instruct-R-21-09-24 с помощью инференс сервера vllm. Формат общения с моделью - OpenAI API. Скачать модель: https://huggingface.co/Vikhrmodels/Vikhr-Llama3.1-8B-Instruct-R-21-09-24
docker run --detach --restart always --name Vikhrmodels_Vikhr-Llama3.1-8B-Instruct-R-21-09-24 --runtime nvidia --gpus device=0 --shm-size 8g -v ~/.cache/huggingface:/root/.cache/huggingface -v ~/text-generation-webui/models:/data -p 8004:8000 --ipc=host vllm/vllm-openai:v0.5.5 --model /data/awq_models/Vikhrmodels_Vikhr-Llama3.1-8B-Instruct-R-21-09-24 --served-model-name vikhr_llama --dtype bfloat16 --max_model_len 8096 --gpu-memory-utilization 0.4 --kv-cache-dtype fp8




#2)  pdf processing
# Запуск из папки /documents 
cd documents
docker build -t pdf-to-markdown-converter .

# Вставляем в documents/pdfs/ pdf файл. После запуска команды docker run получим .md файл в documents/markdowns/ после завершения обработки.
docker run --rm \
  -v ./documents/pdfs:/app/pdfs \
  -v ./documents/markdowns:/app/markdowns \
  -e PDF_FOLDER=/app/pdfs \
  -e MARKDOWN_FOLDER=/app/markdowns \
  pdf-to-markdown-converter


#3) #Запускаем заполнение базы. Запуск из папки /import. Положить в /import/md_files/example.md наш файл .md из прошлого шага
cd import
docker build -t kg-processor .
docker run \
  -e OPENAI_API_KEY=your_openai_api_key \
  -e OPENAI_API_BASE="http://0.0.0.0.0:8004/v1" \  #хост и порт где запустили vllm-server с моделью vikhr
  -e NEO4J_PASSWORD=password \
  -e NEO4J_URI="bolt://0.0.0.0:7687" \
  -e NEO4J_USERNAME="neo4j" \
  -e NEO4J_DATABASE="hackaton" \
  -v ./md_files/example.md:/app/example.md \
  kg-processor example.md --document_name "Example" --chunk_size 250 --chunk_overlap 30
#Заполняем граф, по результатам заполнения высветится лог. 

#Можем зайти в neo4j и высветить наш граф

#4) Запускаем фаст апи сервер, который отвечает на наш вопрос по загруженному документу
cd retriever
docker build -t retriever .
docker run \
  -e OPENAI_API_KEY=your_openai_api_key \
  -e OPENAI_API_BASE="http://0.0.0.0.0:8004/v1" \  #хост и порт где запустили vllm-server с моделью vikhr
  -e NEO4J_PASSWORD=password \
  -e NEO4J_URI="bolt://0.0.0.0:7687" \
  -e NEO4J_USERNAME="neo4j" \
  -e NEO4J_DATABASE="hackaton" \
  -e EMBEDDINGS_SERVER_URL="http://0.0.0.0:8000" \
  retriever 






