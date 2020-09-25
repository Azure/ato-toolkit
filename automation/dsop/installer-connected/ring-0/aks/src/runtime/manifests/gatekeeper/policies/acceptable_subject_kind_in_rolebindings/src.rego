package com.microsoft.c12.acceptablesubjectkindinrolebindings

violation[{"msg": msg}] {
  subject := input.review.object.subjects[_]
  kindofsubject := subject.kind
  satisfied := [good | allowedsubjectkind := input.parameters.allowedsubjectkinds[_] ; good = equal(kindofsubject, allowedsubjectkind)]
  not any(satisfied)
  msg := sprintf("The role binding called %v uses a %v object to scope access. This is not allowed. Only the following kinds are allowed: %s.", [input.review.object.metadata.name, kindofsubject, input.parameters.allowedsubjectkinds])
  }