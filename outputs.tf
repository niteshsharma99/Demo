output "ec2_instance_id" {
  value = aws_instance.demo_ec2.id
}

output "lambda_name" {
  value = aws_lambda_function.restart_lambda.function_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alert_topic.arn
}
