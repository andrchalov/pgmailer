import os


def get_config(template):
    missing_keys = set([d[0] for d in filter(lambda definition: definition[2], template)]) - set(os.environ.keys())
    if missing_keys:
        raise RuntimeError("Not all configuration variables specified: %s" % missing_keys)

    return {
        definition[0]: os.environ.get(definition[0], definition[1])
        for definition in template
    }
