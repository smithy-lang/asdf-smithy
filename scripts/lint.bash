#!/usr/bin/env bash

shellcheck --shell=bash --external-sources \
  bin/* --source-path=template/lib/ \
  lib/* \
  scripts/*

shfmt --language-dialect bash --indent 2 \
  --case-indent --diff ./**/*
