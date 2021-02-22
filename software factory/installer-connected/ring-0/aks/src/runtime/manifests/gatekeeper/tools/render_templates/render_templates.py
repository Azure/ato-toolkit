#!/usr/bin/env python3

from jinja2 import Template, Environment
import yaml

def pretty(d, indent=10, result=""):
    for key, value in iter(d.items()):
        result += " " * indent + str(key)
        if isinstance(value, dict):
            result = pretty(value, indent + 2, result + ":\n")
        else:
            result += ": \"" + str(value) + "\"\n"
    return result

env = Environment()
env.filters['pretty'] = pretty

# Open Policy List
with open('../../policies.yaml') as f:
    policies = yaml.safe_load(f)

# Constraint template ... template -_-
with open("constraint_template.jinja") as t:
    raw = t.read()
    template = env.from_string(raw)

# Constraint .. template
with open("constraint.jinja") as t:
    raw = t.read()
    constraint = Template(raw)

# loop over the policies
for policy in policies:

    print(f'Writing files for {policy["name"]}')

    # Get the rego policy file
    with open(f'../../policies/{policy["name"]}/src.rego') as f:
        data = f.read()

    # Render the Constraint template from the constraint template template
    with open(f'../../k8s_objects/{policy["name"]}-template.yaml', 'w+') as t:
        t.write(template.render(name=policy["name"], kind=policy["CRD"]["kind"], rego=data, properties=policy["properties"]))

    # Render the Constraint from the constraint template
    with open(f'../../k8s_objects/{policy["name"]}-constraint.yaml', 'w+') as c:
        c.write(constraint.render(name=policy["name"], kind=policy["CRD"]["kind"], match=policy["match"], properties=policy["properties"]))