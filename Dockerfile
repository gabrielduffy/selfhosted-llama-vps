# BenemaxGPT - Versão 15 (Definitiva - Rebranding & Funcionalidade)
FROM ghcr.io/open-webui/open-webui:ollama

# 1. Configurações de Marca e Ambiente
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"

# 2. Gestão de Assets (Expurgo Total do Branding Original)
COPY logobenemax.png /app/benemax_logo.png

RUN # Substituição física de todos os ícones e logos para remover rastro do 'OI'
RUN find /app -name "*favicon*" -exec cp /app/benemax_logo.png {} \; && \
    find /app -name "*logo*" -exec cp /app/benemax_logo.png {} \; && \
    find /app -name "*apple-touch-icon*" -exec cp /app/benemax_logo.png {} \; && \
    mkdir -p /app/backend/open_webui/static && \
    cp /app/benemax_logo.png /app/build/logo.png && \
    cp /app/benemax_logo.png /app/build/favicon.png && \
    cp /app/benemax_logo.png /app/backend/open_webui/static/logo.png

# 3. Criação do CSS Mestre (Foco em Contraste e Interatividade)
# Sem hacks ou comandos sed complexos no conteúdo do CSS
RUN echo "\
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap'); \
    body { background: #050508 !important; color: #ffffff !important; font-family: 'Poppins', sans-serif !important; } \
    \
    /* Preloader Fix */ \
    #logo-container, .loading-screen, #splash-screen { background: #050508 !important; } \
    #logo-container svg, .loading-screen svg { display: none !important; } \
    #logo-container::after { content: ''; display: block; width: 80px; height: 80px; background: url('/logo.png') no-repeat center; background-size: contain; animation: pulse 2s infinite; } \
    @keyframes pulse { 0%, 100% { opacity: 0.5; } 50% { opacity: 1; } } \
    \
    /* Login Card - FUNCIONALIDADE TOTAL */ \
    .w-full.max-w-md { \
    background: #0f0f12 !important; \
    border: 1px solid #2d2d33 !important; \
    border-radius: 20px !important; \
    padding: 35px !important; \
    box-shadow: 0 20px 50px rgba(0,0,0,0.8) !important; \
    z-index: 10 !important; \
    position: relative !important; \
    } \
    \
    /* Labels e Títulos */ \
    h2, label, span, p, .text-sm { color: #ffffff !important; opacity: 1 !important; font-weight: 600 !important; } \
    \
    /* Inputs - Estilo Visível e Clicável */ \
    input { \
    background: #1a1a1f !important; \
    border: 1px solid #3f3f46 !important; \
    color: #ffffff !important; \
    border-radius: 10px !important; \
    padding: 12px 15px !important; \
    width: 100% !important; \
    margin-bottom: 5px !important; \
    pointer-events: auto !important; \
    } \
    input:focus { border-color: #00A3FF !important; outline: none !important; } \
    \
    /* Logo Benemax no formulário */ \
    h2::before { \
    content: ''; display: block; width: 80px; height: 80px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    margin: 0 auto 15px; \
    } \
    \
    /* Botão Entrar */ \
    button[type='submit'] { \
    background: #00A3FF !important; \
    color: white !important; \
    font-weight: 700 !important; \
    height: 50px !important; \
    border-radius: 10px !important; \
    margin-top: 20px !important; \
    cursor: pointer !important; \
    border: none !important; \
    } \
    \
    /* ABA DE CADASTRO - DESTAQUE E CLIQUE */ \
    .mt-4.text-center, .mt-6.text-center { margin-top: 30px !important; } \
    a[href*='/auth/signup'] { \
    display: block !important; \
    padding: 12px !important; \
    background: rgba(0, 163, 255, 0.1) !important; \
    border: 2px solid #00A3FF !important; \
    color: #ffffff !important; \
    border-radius: 10px !important; \
    text-align: center !important; \
    font-weight: 700 !important; \
    text-decoration: none !important; \
    } \
    a[href*='/auth/signup']:hover { background: #00A3FF !important; } \
    " > /app/build/benemax.css

# 4. Injeção e Limpeza de Nome
RUN sed -i 's|</head>|<link rel="stylesheet" href="/benemax.css"></head>|' /app/build/index.html && \
    find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} +

# 5. Configuração de Portas e Startup
EXPOSE 8080
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
