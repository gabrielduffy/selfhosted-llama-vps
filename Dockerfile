# BenemaxGPT - Versão 17 (OVERHAUL TOTAL - DESIGN PREMIUM & FUNCIONAL)
FROM ghcr.io/open-webui/open-webui:ollama

# 1. Configurações de Marca e Ambiente
ENV WEBUI_NAME="BenemaxGPT"
ENV WEBUI_URL="https://gpt.benemax.com.br/"
ENV WEBUI_SECRET_KEY="benemax_secret_key_change_me"
ENV WEBUI_AUTH=True
ENV ENABLE_SIGNUP=True
ENV DEFAULT_USER_ROLE="user"

# 2. Gestão de Assets (Expurgo Físico Massivo)
COPY logobenemax.png /app/benemax_logo.png

# Substituição física e criação de diretórios de segurança
RUN mkdir -p /app/backend/open_webui/static && \
    find /app -name "*favicon*" -exec cp /app/benemax_logo.png {} \; && \
    find /app -name "*logo*" -exec cp /app/benemax_logo.png {} \; && \
    find /app -name "*apple-touch-icon*" -exec cp /app/benemax_logo.png {} \; && \
    cp /app/benemax_logo.png /app/build/logo.png && \
    cp /app/benemax_logo.png /app/build/favicon.png && \
    cp /app/benemax_logo.png /app/backend/open_webui/static/logo.png

# 3. Engenharia de Injeção - CSS Mestre e JS de Inicialização
# Criamos um arquivo isolado para evitar erros de escape no sed
RUN echo " \
    <script> \
    /* Forçar Dark Mode Nativo */ \
    localStorage.setItem('theme', 'dark'); \
    document.documentElement.classList.add('dark'); \
    \
    /* Correção Dinâmica de Texto */ \
    document.addEventListener('DOMContentLoaded', () => { \
    const observer = new MutationObserver(() => { \
    document.title = 'BenemaxGPT'; \
    const signupLink = document.querySelector('a[href*=\"/auth/signup\"]'); \
    if (signupLink && !signupLink.classList.contains('benemax-styled')) { \
    signupLink.innerText = 'CRIE SUA CONTA AQUI'; \
    signupLink.classList.add('benemax-styled'); \
    } \
    }); \
    observer.observe(document.body, { childList: true, subtree: true }); \
    }); \
    </script> \
    <style> \
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap'); \
    \
    :root { --benemax-blue: #00A3FF; --bg-deep: #050508; } \
    \
    body { \
    background-color: var(--bg-deep) !important; \
    color: #FFFFFF !important; \
    font-family: 'Inter', sans-serif !important; \
    -webkit-font-smoothing: antialiased; \
    } \
    \
    /* Preloader Premium */ \
    #logo-container, .loading-screen, #splash-screen { background: var(--bg-deep) !important; opacity: 1 !important; } \
    #logo-container svg, .loading-screen svg { display: none !important; } \
    #logo-container::after { \
    content: ''; display: block; width: 100px; height: 100px; \
    background: url('/logo.png') no-repeat center; background-size: contain; \
    animation: pulseBenemax 2s ease-in-out infinite; \
    } \
    @keyframes pulseBenemax { 0%, 100% { transform: scale(0.95); opacity: 0.6; } 50% { transform: scale(1.05); opacity: 1; } } \
    \
    /* Login Card - Glassmorphism Funcional (Sem bloquear cliques) */ \
    .w-full.max-w-md { \
    background: rgba(17, 17, 20, 0.8) !important; \
    backdrop-filter: blur(20px) !important; \
    -webkit-backdrop-filter: blur(20px) !important; \
    border: 1px solid rgba(255, 255, 255, 0.1) !important; \
    border-radius: 24px !important; \
    padding: 40px !important; \
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5) !important; \
    z-index: 100 !important; \
    position: relative !important; \
    pointer-events: auto !important; \
    } \
    \
    /* Inputs Blindados - Alta Visibilidade */ \
    label, h2, span, p { color: #FFFFFF !important; font-weight: 600 !important; margin-bottom: 8px !important; display: block; } \
    input { \
    background: rgba(255, 255, 255, 0.05) !important; \
    border: 1px solid rgba(255, 255, 255, 0.1) !important; \
    color: #FFFFFF !important; \
    border-radius: 12px !important; \
    padding: 14px 16px !important; \
    font-size: 16px !important; \
    width: 100% !important; \
    outline: none !important; \
    transition: all 0.2s ease; \
    } \
    input:focus { border-color: var(--benemax-blue) !important; background: rgba(255, 255, 255, 0.08) !important; } \
    \
    /* Buttons */ \
    button[type='submit'] { \
    background: var(--benemax-blue) !important; \
    color: #FFFFFF !important; \
    font-weight: 700 !important; \
    letter-spacing: 0.5px; \
    text-transform: uppercase; \
    border-radius: 12px !important; \
    height: 54px !important; \
    margin-top: 10px !important; \
    cursor: pointer !important; \
    border: none !important; \
    transition: transform 0.2s ease; \
    } \
    button[type='submit']:hover { transform: translateY(-2px); filter: brightness(1.1); } \
    \
    /* Cadastro - Call to Action Premium */ \
    a[href*='/auth/signup'] { \
    display: block !important; \
    margin-top: 25px !important; \
    padding: 16px !important; \
    background: linear-gradient(90deg, rgba(0, 163, 255, 0.1), rgba(0, 163, 255, 0.05)) !important; \
    border: 1px dashed var(--benemax-blue) !important; \
    color: var(--benemax-blue) !important; \
    border-radius: 12px !important; \
    text-align: center !important; \
    font-weight: 700 !important; \
    text-decoration: none !important; \
    transition: all 0.3s ease; \
    } \
    a[href*='/auth/signup']:hover { background: var(--benemax-blue) !important; color: #FFF !important; border-style: solid !important; } \
    \
    /* Esconder Ícones de Chat Originais */ \
    aside svg[width='24'] { color: var(--benemax-blue) !important; } \
    </style> " > /app/benemax-v17.html

# 4. Aplicação Final (Injeção Segura e Limpeza)
RUN sed -i 's|</head>|'"$(cat /app/benemax-v17.html)"'</head>|' /app/build/index.html && \
    find /app -type f \( -name "*.html" -o -name "*.js" \) -exec sed -i 's/Open WebUI/BenemaxGPT/g' {} +

EXPOSE 8080
ENV OLLAMA_NUM_PARALLEL=1
ENV OLLAMA_MAX_LOADED_MODELS=1

RUN echo '#!/bin/bash\n\
    ollama serve & \n\
    sleep 5 \n\
    ollama pull llama3.1:8b \n\
    wait' > /usr/bin/start_llama.sh && chmod +x /usr/bin/start_llama.sh
