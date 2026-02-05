# Moved blocks (Terraform 1.1+)
# Version-controlled refactoring that Terraform handles automatically

# Example 1: Rename a resource
moved {
  from = aws_instance.web
  to   = aws_instance.application
}

# Example 2: Move into a module
moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.web
}

# Example 3: Move out of a module
moved {
  from = module.legacy.aws_instance.web
  to   = aws_instance.web
}

# Example 4: Rename a module
moved {
  from = module.old_name
  to   = module.new_name
}

# Example 5: Change from count to for_each
# When changing from count to for_each, you need individual moves
moved {
  from = aws_subnet.private[0]
  to   = aws_subnet.private["eu-west-1a"]
}

moved {
  from = aws_subnet.private[1]
  to   = aws_subnet.private["eu-west-1b"]
}

# Example 6: Move resource within nested modules
moved {
  from = module.app.module.network.aws_security_group.main
  to   = module.security.aws_security_group.app
}

# Important: Keep moved blocks for at least one release cycle
# After everyone has applied, you can remove them
