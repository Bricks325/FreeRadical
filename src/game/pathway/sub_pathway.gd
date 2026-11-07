#@tool
extends Path2D
class_name SubPathway
## 子路径。
##
## [SubPathway] 用于表示 [Pathway] 上的一个子路径。


## 路径索引。
var pathway_index: int
## 子路径索引。
var index: int
## 子路径长度。
var length: float
## 采样器。
var follow: PathFollow2D
## 节点列表。
var nodes: Array[PathwayNode]
