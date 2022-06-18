LOG_HASH="%C(always,yellow)%h%C(always,reset)"
LOG_RELATIVE_TIME="%C(always,green)(%ar)%C(always,reset)"
LOG_AUTHOR="%C(always,blue)<%an>%C(always,reset)"
LOG_SUBJECT="%s"
LOG_REFS="%C(always,red)%d%C(always,reset)"

LOG_FORMAT="$LOG_HASH}$LOG_RELATIVE_TIME}$LOG_AUTHOR}$LOG_REFS $LOG_SUBJECT"
STAT_FORMAT=""

BRANCH_PREFIX="%(HEAD)"
BRANCH_REF="%(color:red)%(color:bold)%(refname:short)%(color:reset)"
BRANCH_HASH="%(color:yellow)%(objectname:short)%(color:reset)"
BRANCH_DATE="%(color:green)(%(committerdate:relative))%(color:reset)"
BRANCH_AUTHOR="%(color:blue)%(color:bold)<%(authorname)>%(color:reset)"
BRANCH_CONTENTS="%(contents:subject)"

BRANCH_FORMAT="$BRANCH_PREFIX}$BRANCH_REF}$BRANCH_HASH}$BRANCH_DATE}$BRANCH_AUTHOR}$BRANCH_CONTENTS"

show_git_head() {
  pretty_git_log -1
  git show -p --pretty="tformat:"
}

pretty_git_log() {
  git log --color --pretty="tformat:${LOG_FORMAT}" $* | pretty_git_format | git_page_maybe
}

pretty_git_branch() {
  git branch -v --color=always --format=${BRANCH_FORMAT} $* | pretty_git_format
}

pretty_git_branch_sorted() {
	git branch -v --color=always --format=${BRANCH_FORMAT} --sort=-committerdate $* | pretty_git_format
}

show_git_diff() {
	# git diff --color=always $* | git_page_maybe
	git diff --color=always $*
}

show_git_diff_fancy() {
	git diff --color=always $* | git_page_maybe --pattern '^(Date|added|deleted|modified): '
}

show_git_stat() {
	git diff --color=always --stat $* | git_page_maybe
}

show_git_stash() {
	git stash list $* | git_page_maybe
}

pretty_git_format() {
  # Replace (2 years ago) with (2 years)
  sed -Ee 's/(^[^<]*) ago\)/\1)/' |
  # Replace (2 years, 5 months) with (2 years)
  sed -Ee 's/(^[^<]*), [[:digit:]]+ .*months?\)/\1)/' |
  # Line columns up based on } delimiter
  column -s '}' -t
}

git_page_maybe() {
  # Page only if we're asked to.
  if [ -n "$GIT_NO_PAGER" ]; then
    cat
  else
    # Page only if needed.
		# passing it --mouse flag breaks higlighting?
    less --quit-if-one-screen --no-init --RAW-CONTROL-CHARS --chop-long-lines --quit-on-intr --squeeze-blank-lines $*
  fi
}
