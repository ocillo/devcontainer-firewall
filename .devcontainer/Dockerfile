FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm

ARG USERNAME=node

# Ensure the node user owns a global npm prefix directory so we can install CLI tooling.
RUN mkdir -p /home/${USERNAME}/.npm-global \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.npm-global

ENV NPM_CONFIG_PREFIX=/home/${USERNAME}/.npm-global
ENV PATH=${PATH}:/home/${USERNAME}/.npm-global/bin

# Prepare directories that will later be backed by devcontainer volumes for CLI auth.
RUN mkdir -p /home/${USERNAME}/.claude /home/${USERNAME}/.codex \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.claude /home/${USERNAME}/.codex

USER ${USERNAME}

# Install Claude Code and Codex CLIs globally via npm.
RUN npm install -g @anthropic-ai/claude-code@latest @openai/codex@latest
