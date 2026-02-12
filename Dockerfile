# Usamos a imagem oficial que integra Ollama + Open WebUI
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações para otimizar o uso em CPU
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_INTEL_GPU=false
ENV OLLAMA_AMD_GPU=false

# Expor as portas necessárias
# 8080: Open WebUI (Interface)
# 11434: Ollama API
EXPOSE 8080
EXPOSE 11434

# Script para baixar o modelo Llama-3.1 durante o primeiro BOOT se não existir
# Isso evita que a imagem Docker fique pesada demais (>5GB) no repositório,
# mas garante que o modelo esteja lá assim que o container subir.
RUN echo '#!/bin/bash\n\
ollama serve & \n\
sleep 5 \n\
echo "Verificando/Baixando Llama-3.1-8B..." \n\
ollama pull llama3.1:8b \n\
echo "Llama-3.1 pronto!" \n\
wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh

# Mantemos o entrypoint original da imagem, que já gerencia ambos os processos
# Mas você pode usar o Open WebUI para baixar outros modelos via interface depois.
