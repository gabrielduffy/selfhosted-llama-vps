# Usamos a imagem oficial que integra Ollama + Open WebUI
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Branding
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://llm.ax5glv.easypanel.host/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True

# Injeção de CSS Agressiva (Poppins em tudo e esconder sufixos)
ENV CUSTOM_INTERFACE_CSS=" \
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap'); \
    * { font-family: 'Poppins', sans-serif !important; } \
    :root { --primary: #8B2CE5 !important; --accent: #00A3FF !important; } \
    "

# Copiamos a logo para a raiz do build
COPY logobenemax.png /app/build/logo.png
COPY logobenemax.png /app/build/favicon.png

# ----- ESTRATÉGIA DE SUBSTITUIÇÃO TOTAL -----
# 1. Copiamos a logo
COPY logobenemax.png /app/build/logo.png
COPY logobenemax.png /app/build/favicon.png

# 2. Varredura completa para trocar textos e garantir a logo
RUN find /app/build -type f -exec sed -i 's/ (Open WebUI)//g' {} + && \
    find /app/build -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} + && \
    cp /app/build/logo.png /app/build/favicon.ico

# Forçamos as variáveis de sistema
ENV WEBUI_FAVICON_URL="/logo.png"
ENV WEBUI_LOGO_URL="/logo.png"
ENV GLOBAL_TITLE_TEMPLATE="BenemaxGPT"

# Configurações para otimizar o uso em CPU e Persistência de Modelos
ENV OLLAMA_MODELS="/app/backend/data/ollama/models"
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_INTEL_GPU=false
ENV OLLAMA_AMD_GPU=false

# Expor as portas necessárias
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
