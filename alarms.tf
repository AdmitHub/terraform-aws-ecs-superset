resource "aws_sns_topic" "alarms" {
  name = "superset-prod-alarm-notifications"
  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "latency-p99" {
  alarm_name          = "superset-prod-latency-p99"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  datapoints_to_alarm = 5
  threshold           = 20
  alarm_description   = "Monitor Superset ELB latency"
  extended_statistic  = "p99"
  dimensions = {
    LoadBalancer = aws_lb.public.arn_suffix
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]

  tags = local.common_tags
}

