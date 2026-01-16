extends Node2D

@onready var wheel_metrics_ff: WheelMetrics = %WheelMetrics_FF
@onready var wheel_metrics_fr: WheelMetrics = %WheelMetrics_FR
@onready var wheel_metrics_f4: WheelMetrics = %WheelMetrics_F4
@onready var wheel_metrics_mr: WheelMetrics = %WheelMetrics_MR
@onready var wheel_metrics_rr: WheelMetrics = %WheelMetrics_RR

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    wheel_metrics_ff.update_powertrain(PowertrainLayout.FF)
    wheel_metrics_fr.update_powertrain(PowertrainLayout.FR)
    wheel_metrics_f4.update_powertrain(PowertrainLayout.F4)
    wheel_metrics_mr.update_powertrain(PowertrainLayout.MR)
    wheel_metrics_rr.update_powertrain(PowertrainLayout.RR)
