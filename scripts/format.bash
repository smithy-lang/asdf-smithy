#!/usr/bin/env bash

shfmt --language-dialect bash --indent 2 \
  --case-indent --write ./**/*
