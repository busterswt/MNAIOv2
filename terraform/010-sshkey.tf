# Define ssh to config in instance

resource "openstack_compute_keypair_v2" "user_key" {
  name       = "user-key"
#  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDM2wIxIr8Wk5b/Bxnjokylmv16ZF+W5cCZu+GcGwud91PI32AnxrDJ/uXRfHDYzJgumgVDkhHELkh1TQAY4kKzOTWnuW+4QiKUHY9He5cFoMMzX1N5zF5EEgpVwhu3doGstam+bQ60rMRJXwS+XTjf9VUHDjiBMJ1hYhwN1nurmDRKL3U/9xhQ0fT+tMwjpbsNqKWUt5SugYJw5V+v93F/aHPIdboDY4lNokdgM/I1pLuY4AzNgEZWXRV9wDydKyXRKaX/WX95etOk8hrmIqGtBZrNqkfPi80+1k/mevM3QKHVplFTHwgTmt7jxOLRqkbJncxUclBpeyu+Pef0jAU/"
}

