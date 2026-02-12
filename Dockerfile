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
    } \
    "

# Copiamos a logo de referência
COPY logobenemax.png /app/logobenemax_source.png

# ----- ESTRATÉGIA RADICAL DE REBRANDING (V8 - FRONTEND FIX) -----

# 1. Preparação das Pastas e Logos no local correto do Frontend
RUN mkdir -p /app/build/static
COPY logobenemax.png /app/build/logo.png
COPY logobenemax.png /app/build/favicon.png
COPY logobenemax.png /app/backend/open_webui/static/logo.png

# 2. Criação do arquivo CSS mestre no local de build do site
RUN echo " \
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap'); \
    * { font-family: 'Poppins', sans-serif !important; } \
    body { background: #050508 !important; color: white !important; margin: 0; overflow-x: hidden; } \
    #logo-container, .loading-screen, #splash-screen { background: #050508 !important; display: flex !important; justify-content: center !important; align-items: center !important; } \
    #logo-container svg, .loading-screen svg { display: none !important; } \
    #logo-container::after, .loading-screen::after { \
    content: ''; display: block; width: 120px; height: 120px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    filter: drop-shadow(0 0 15px rgba(139, 44, 229, 0.6)); \
    animation: pulse 2s infinite; \
    } \
    @keyframes pulse { 0% { opacity: 0.6; transform: scale(0.95); } 50% { opacity: 1; transform: scale(1); } 100% { opacity: 0.6; transform: scale(0.95); } } \
    /* Card de Login Glassmorphism */ \
    .w-full.max-w-md, [class*='auth-card'], .bg-gray-50, .bg-white { \
    background: rgba(255, 255, 255, 0.02) !important; \
    backdrop-filter: blur(35px) !important; \
    border: 1px solid rgba(255, 255, 255, 0.08) !important; \
    border-radius: 30px !important; \
    padding: 2.5rem !important; \
    color: white !important; \
    } \
    button[type='submit'], .bg-primary { \
    background: linear-gradient(135deg, #8B2CE5 0%, #00A3FF 100%) !important; \
    border: none !important; box-shadow: 0 0 25px rgba(139, 44, 229, 0.4) !important; \
    border-radius: 12px !important; font-weight: 600 !important; \
    } \
    .text-2xl.font-medium::before { \
    content: ''; display: block; width: 90px; height: 90px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    margin: 0 auto 30px; \
    } \
    /* Estilizando o link de Cadastro para parecer uma aba ou botão de destaque */ \
    a[href*='/auth/signup'], .text-primary-600 { \
    color: #00A3FF !important; \
    font-weight: 700 !important; \
    border: 1px solid rgba(0, 163, 255, 0.3); \
    padding: 5px 15px; border-radius: 20px; \
    transition: all 0.3s ease; \
    } \
    a[href*='/auth/signup']:hover { \
    background: rgba(0, 163, 255, 0.1); \
    border-color: #00A3FF; \
    } \
    " > /app/build/benemax.css

# 3. Injeção direta no index.html do FRONTEND
RUN sed -i 's|</head>|<link rel="stylesheet" href="/benemax.css"></head>|' /app/build/index.html && \
    find /app -name "favicon*" -exec cp /app/build/logo.png {} \; && \
    find /app -name "logo*" -exec cp /app/build/logo.png {} \; && \
    find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} + && \
    find /app -type f -exec sed -i 's/ (Open WebUI)//g' {} +

# 4. Configurações de Ambiente Final
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"
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
