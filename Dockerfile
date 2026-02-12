# Usamos a imagem oficial que integra Ollama + Open WebUI
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Branding e Persistência
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://llm.ax5glv.easypanel.host/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True

# Configurações para otimizar o uso em CPU e Persistência de Modelos
ENV OLLAMA_MODELS="/app/backend/data/ollama/models"
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_INTEL_GPU=false
ENV OLLAMA_AMD_GPU=false

# Injeção de CSS Agressiva (Poppins em tudo)
ENV CUSTOM_INTERFACE_CSS=" \
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap'); \
    * { font-family: 'Poppins', sans-serif !important; } \
    :root { --primary: #8B2CE5 !important; --accent: #00A3FF !important; } \
    "

# Copiamos a logo de referência
COPY logobenemax.png /app/logobenemax_source.png

# ----- ESTRATÉGIA RADICAL DE REBRANDING -----
# 1. Substitui fisicamente TODOS os ícones do sistema pela nossa logo
# 2. Varredura TOTAL em /app para apagar "Open WebUI" e o sufixo
# 3. Força a fonte Poppins no HTML e remove o título original
RUN find /app -name "favicon*" -exec cp /app/logobenemax_source.png {} \; && \
    find /app -name "logo*" -exec cp /app/logobenemax_source.png {} \; && \
    find /app -name "apple-touch-icon*" -exec cp /app/logobenemax_source.png {} \; && \
    find /app -type f \( -name "*.html" -o -name "*.js" -o -name "*.json" -o -name "*.css" \) -exec sed -i 's/ (Open WebUI)//g' {} + && \
    find /app -type f \( -name "*.html" -o -name "*.js" -o -name "*.json" \) -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} + && \
    find /app -type f -name "index.html" -exec sed -i 's#</head>#<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;700\&display=swap" rel="stylesheet"><style>* { font-family: "Poppins", sans-serif !important; }</style></head>#' {} +

# Forçamos variáveis finais
ENV WEBUI_FAVICON_URL="/favicon.png"
ENV WEBUI_LOGO_URL="/logo.png"
ENV GLOBAL_TITLE_TEMPLATE="BenemaxGPT"

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
