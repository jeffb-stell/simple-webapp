#!/usr/bin/env bats

@test "apachectl binary is found in PATH" {
  run which apachectl
  [ "$status" -eq 0 ]
}