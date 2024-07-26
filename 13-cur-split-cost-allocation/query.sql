SELECT 
  DATE_FORMAT(
    DATE_TRUNC(
      'day', "line_item_usage_start_date"
    ), 
    '%Y-%m-%d'
  ) AS "date",
  "line_item_resource_id" AS "resource_id",
  ARBITRARY(CONCAT(
    REPLACE(
      SPLIT_PART(
        "line_item_resource_id", 
        '/', 1
      ), 
      'pod', 
      'cluster'
    ), 
    '/', 
    SPLIT_PART(
      "line_item_resource_id", 
      '/', 2
    )
  )) AS "cluster_arn", 
  ARBITRARY(SPLIT_PART(
    "line_item_resource_id", 
    '/', 2
  )) AS "cluster_name", 
  ARBITRARY("split_line_item_parent_resource_id") AS "node_instance_id", 
  ARBITRARY("resource_tags_aws_eks_node") AS "node_name", 
  ARBITRARY(SPLIT_PART(
    "line_item_resource_id", 
    '/', 3
  )) AS "namespace",
  ARBITRARY("resource_tags_aws_eks_workload_type") AS "controller_kind", 
  ARBITRARY("resource_tags_aws_eks_workload_name") AS "controller_name", 
  ARBITRARY("resource_tags_aws_eks_deployment") AS "deployment",
  ARBITRARY(SPLIT_PART(
    "line_item_resource_id", 
    '/', 4
  )) AS "pod_name", 
  ARBITRARY(SPLIT_PART(
    "line_item_resource_id", 
    '/', 5
  )) AS "pod_uid", 
  SUM(
    CASE WHEN "line_item_usage_type" LIKE '%EKS-EC2-vCPU-Hours' THEN "split_line_item_split_cost" + "split_line_item_unused_cost" ELSE 0.0 END
  ) AS "cpu_cost", 
  SUM(
    CASE WHEN "line_item_usage_type" LIKE '%EKS-EC2-GB-Hours' THEN "split_line_item_split_cost" + "split_line_item_unused_cost" ELSE 0.0 END
  ) AS "ram_cost", 
  SUM(
    "split_line_item_split_cost" + "split_line_item_unused_cost"
  ) AS "total_cost" 
FROM 
  cur
WHERE 
  "line_item_operation" = 'EKSPod-EC2' 
  AND CURRENT_DATE - INTERVAL '7' DAY <= "line_item_usage_start_date" 
GROUP BY 
  1, 
  2
ORDER BY 
  "cluster_arn", 
  "date" DESC