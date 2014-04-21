import json

class Registry:
    def __init__(self, filename):
        self.potato = json.loads(open(filename).read())["hooks"]

    def notify(self, repo, branch, sha):
        fn = self.file_for(repo, branch)

        if fn is None:
            return

        with open(fn, "w") as f:
            f.write(sha)

    def file_for(self, repo, branch):
        candidates = [
            hook["file"]
            for hook in self.potato
            if hook["repository"] == repo and
               hook["branch"] == branch]

        if len(candidates) == 0:
            return None
        else:
            return candidates[0]

