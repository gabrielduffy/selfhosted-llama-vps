# Self-Hosted LLM (Llama-3.1) para Easypanel

Este repositório contém a configuração para rodar uma LLM completa (Interface + API) em uma VPS usando Easypanel.

## 🚀 Como instalar no Easypanel

1. Crie um novo **App** no Easypanel.
2. Na aba **Source**, conecte este repositório GitHub.
3. Na aba **Domains**, configure o seu domínio ou use um subdomínio para acessar a interface.
4. Na aba **Storage**, crie um volume persistente:
   - **Mount Path:** `/app/backend/data`
5. Na aba **Environment**, você pode adicionar:
   - `WEBUI_SECRET_KEY`: (uma string aleatória para segurança)

## 🖥️ Acesso
- **Interface:** `http://seu-dominio:8080`
- **API (estilo OpenAI):** `http://seu-dominio:11434/v1`

## 🧠 Modelos
Por padrão, este o container tentará baixar o `llama3.1:8b`. Você pode baixar outros (ex: `glm4`) diretamente pela interface do Open WebUI em:
*Settings -> Models -> Pull a model from Ollama.com*
