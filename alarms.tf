locals {
  healthy_host_threshold = 1
}
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

resource "aws_cloudwatch_metric_alarm" "healthy_hosts" {
  alarm_name                = "superset-prod-healthy-hosts"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 3
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Minimum"
  threshold                 = local.healthy_host_threshold
  unit                      = "Count"
  alarm_description         = "Less than ${local.healthy_host_threshold} healthy host(s)"
  treat_missing_data        = "breaching"
  alarm_actions             = [aws_sns_topic.alarms.arn]
  ok_actions                = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = [aws_sns_topic.alarms.arn]
  dimensions = {
    TargetGroup  = module.superset-core.target_group_suffix
    LoadBalancer = aws_lb.public.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  alarm_name                = "superset-prod-http-5xx"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "HTTPCode_ELB_5XX_Count"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 5
  unit                      = "Count"
  alarm_description         = "More than 5 5xx's in both of the last two minutes"
  treat_missing_data        = "notBreaching"
  alarm_actions             = [aws_sns_topic.alarms.arn]
  ok_actions                = [aws_sns_topic.alarms.arn]
  insufficient_data_actions = [aws_sns_topic.alarms.arn]
  dimensions = {
    TargetGroup  = module.superset-core.target_group_suffix
    LoadBalancer = aws_lb.public.arn_suffix
  }
}
