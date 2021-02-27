node /^masterha00\d$/ {
  include 'base'
  include 'masterha'
}

node /^db00\d$/ {
  include 'base'
  include 'db'
}
