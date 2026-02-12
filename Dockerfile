# Usamos a imagem oficial estável
FROM ghcr.io/open-webui/open-webui:ollama

# Configurações de Marca Únicas
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"

# Copiamos a logo Benemax
COPY logobenemax.png /app/logobenemax_source.png

# ----- V13: EXTERMÍNIO TOTAL DA MARCA ORIGINAL -----

# 1. Substituição Massiva de Assets
# Removemos e substituímos fisicamente qualquer imagem original
RUN find /app -name "favicon*" -exec cp /app/logobenemax_source.png {} \; && \
    find /app -name "logo*" -exec cp /app/logobenemax_source.png {} \; && \
    find /app -name "apple-touch-icon*" -exec cp /app/logobenemax_source.png {} \; && \
    cp /app/logobenemax_source.png /app/build/favicon.png && \
    cp /app/logobenemax_source.png /app/build/logo.png && \
    mkdir -p /app/backend/open_webui/static && \
    cp /app/logobenemax_source.png /app/backend/open_webui/static/logo.png

# 2. Injeção de CSS para Esconder Qualquer Resquício e Corrigir Layout
RUN echo " \
    <style> \
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap'); \
    \
    /* Hide original SVG logos everywhere */ \
    svg, img[src*='favicon'], img[src*='logo'] { display: none !important; } \
    \
    /* Show ONLY Benemax Logo */ \
    body::before { \
    content: ''; display: none; \
    } \
    \
    body { background-color: #050508 !important; color: #ffffff !important; font-family: 'Inter', sans-serif !important; } \
    \
    /* Preloader Fix - Extermínio do SVG original */ \
    #logo-container, .loading-screen, #splash-screen { background: #050508 !important; display: flex !important; justify-content: center !important; align-items: center !important; } \
    #logo-container::after, .loading-screen::after { \
    content: ''; display: block; width: 80px; height: 80px; \
    background: url('/logo.png') no-repeat center !important; \
    background-size: contain !important; \
    animation: pulse 2s infinite; \
    } \
    @keyframes pulse { 0%, 100% { opacity: 0.5; } 50% { opacity: 1; } } \
    \
    /* Login Card - Segurança e Funcionalidade */ \
    .w-full.max-w-md { \
    background: #111114 !important; \
    border: 1px solid #333338 !important; \
    border-radius: 20px !important; \
    padding: 40px !important; \
    box-shadow: 0 20px 50px rgba(0,0,0,0.9) !important; \
    position: relative !important; \
    z-index: 9999 !important; \
    } \
    \
    /* Textos - Contraste Absoluto */ \
    h2, label, span, p, .text-sm, .text-xs { color: #ffffff !important; opacity: 1 !important; font-weight: 600 !important; } \
    \
    /* Inputs - Fundo Escuro com Letra Branca Vibrante */ \
    input { \
    background: #1c1c21 !important; \
    border: 1px solid #444 !important; \
    color: #ffffff !important; \
    border-radius: 10px !important; \
    padding: 15px !important; \
    font-size: 16px !important; \
    width: 100% !important; \
    display: block !important; \
    pointer-events: auto !important; \
    opacity: 1 !important; \
    } \
    input:focus { border-color: #00A3FF !important; } \
    \
    /* Troca da Logo no Formulário */ \
    h2::before { \
    content: ''; display: block; width: 100px; height: 100px; \
    background: url('/logo.png') no-repeat center !important; \
    background-size: contain !important; \
    margin: 0 auto 20px !important; \
    } \
    \
    /* Botão Entrar */ \
    button[type='submit'] { \
    background: #00A3FF !important; \
    color: white !important; \
    font-weight: 700 !important; \
    height: 55px !important; \
    border-radius: 10px !important; \
    margin-top: 20px !important; \
    cursor: pointer !important; \
    width: 100% !important; \
    } \
    \
    /* BOTÃO DE CADASTRO - DESTAQUE TOTAL */ \
    a[href*='/auth/signup'] { \
    display: block !important; \
    margin-top: 30px !important; \
    padding: 15px !important; \
    background: rgba(0, 163, 255, 0.15) !important; \
    border: 2px solid #00A3FF !important; \
    color: #ffffff !important; \
    border-radius: 10px !important; \
    text-align: center !important; \
    font-weight: 700 !important; \
    text-decoration: none !important; \
    } \
    a[href*='/auth/signup']:hover { background: #00A3FF !important; } \
    </style> " > /app/build/branding-fix.html

# 3. Purgação de Texto e Injeção de Código
# Substituímos qualquer ocorrência de "Open WebUI" para "BenemaxGPT" em todo o sistema
RUN find /app -type f -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} + && \
    sed -i 's|</head>|$(cat /app/build/branding-fix.html)</head>|' /app/build/index.html

# 4. Configuração do Servidor
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1
EXPOSE 8080

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
