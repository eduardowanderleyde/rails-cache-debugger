#!/bin/bash

set -euo pipefail

# Verifica se o Ruby está instalado
if ! command -v ruby &> /dev/null; then
    echo "Erro: Ruby não está instalado"
    exit 1
fi

echo "==> Limpando arquivos de lock e bundles antigos..."
rm -f spec/dummy/Gemfile.lock
rm -rf spec/dummy/.bundle
rm -rf .bundle Gemfile.lock

echo "==> Instalando Bundler mais recente..."
gem install bundler --no-document

echo "==> Limpando gems antigas não usadas..."
gem cleanup

echo "==> Instalando dependências do projeto..."
bundle install --jobs=$(nproc) --retry=3

echo "==> Rodando todos os testes (incluindo integração com dummy)..."
bundle exec rspec --format documentation

echo "==> Pronto! Se aparecer algum erro acima, copie e cole aqui para análise." 