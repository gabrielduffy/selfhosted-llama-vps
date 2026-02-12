# Usamos a imagem oficial que integra Ollama + Open WebUI
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Branding e Persistência
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True

# Configurações para otimizar o uso em CPU e Persistência de Modelos
ENV OLLAMA_MODELS="/app/backend/data/ollama/models"
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
ENV OLLAMA_INTEL_GPU=false
ENV OLLAMA_AMD_GPU=false

# Injeção de CSS Agressiva (Poppins, Branding e Auth Page Premium)
ENV CUSTOM_INTERFACE_CSS=" \
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap'); \
    \
    /* Reset e Fonte */ \
    * { font-family: 'Poppins', sans-serif !important; } \
    \
    /* Tema Escuro e Background Neon */ \
    body { \
    background-color: #050508 !important; \
    background-image:  \
    radial-gradient(at 0% 0%, rgba(139, 44, 229, 0.15) 0px, transparent 50%), \
    radial-gradient(at 100% 100%, rgba(0, 163, 255, 0.15) 0px, transparent 50%) !important; \
    height: 100vh !important; \
    color: white !important; \
    } \
    \
    /* Card de Login (Glassmorphism) */ \
    div.flex.flex-col.justify-center.min-h-screen { \
    background: transparent !important; \
    } \
    \
    .w-full.max-w-md { \
    background: rgba(255, 255, 255, 0.03) !important; \
    backdrop-filter: blur(16px) !important; \
    border: 1px solid rgba(255, 255, 255, 0.1) !important; \
    border-radius: 24px !important; \
    padding: 40px !important; \
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5) !important; \
    } \
    \
    /* Injeção da Logomarca Benemax acima do título */ \
    .text-2xl.font-medium::before { \
    content: '' !important; \
    display: block !important; \
    width: 100px !important; \
    height: 100px !important; \
    background: url('/logo.png') no-repeat center !important; \
    background-size: contain !important; \
    margin: 0 auto 30px !important; \
    filter: drop-shadow(0 0 10px rgba(139, 44, 229, 0.5)) !important; \
    } \
    \
    .text-2xl.font-medium { \
    text-align: center !important; \
    font-size: 1.8rem !important; \
    font-weight: 700 !important; \
    margin-bottom: 30px !important; \
    background: linear-gradient(135deg, #fff 0%, #ccc 100%); \
    -webkit-background-clip: text; \
    -webkit-text-fill-color: transparent; \
    } \
    \
    /* Inputs Estilizados */ \
    input { \
    background: rgba(255, 255, 255, 0.05) !important; \
    border: 1px solid rgba(255, 255, 255, 0.1) !important; \
    border-radius: 12px !important; \
    color: white !important; \
    padding: 12px !important; \
    } \
    \
    /* Botão Benemax (Gradiente + Neon) */ \
    button[type='submit'], .bg-primary { \
    background: linear-gradient(135deg, #8B2CE5 0%, #00A3FF 100%) !important; \
    border: none !important; \
    border-radius: 12px !important; \
    font-weight: 700 !important; \
    text-transform: uppercase !important; \
    letter-spacing: 1px !important; \
    box-shadow: 0 4px 15px rgba(139, 44, 229, 0.4) !important; \
    transition: all 0.3s ease !important; \
    cursor: pointer !important; \
    } \
    \
    button[type='submit']:hover { \
    transform: translateY(-2px) !important; \
    box-shadow: 0 8px 25px rgba(0, 163, 255, 0.6) !important; \
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
