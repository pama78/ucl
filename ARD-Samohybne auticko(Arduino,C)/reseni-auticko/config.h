#define TRIGGER_PIN  10
#define ECHO_PIN     12
#define MAX_DISTANCE 300
#define CUR_DIR      1   // 1= "L" 2=R
#define SERVO_LEFT   1   //
#define SERVO_RIGHT   2
#define SERVO_STEPS     30
#define SERVO_LEFT_MIN  15
#define SERVO_RIGHT_MIN  165
#define BUTTON_PIN 13 
#define LED_PIN A1 
#define MOTOR_L 1 // levy motor
#define MOTOR_R 2 // pravy motor
#define MOTOR_L_DIR_PIN 7
#define MOTOR_L_PWM_PIN 6
#define MOTOR_R_DIR_PIN 4
#define MOTOR_R_PWM_PIN 5
#define PWM_SLOW 90  // arbitrary slow speed PWM duty cycle
#define PWM_FAST 160 // arbitrary fast speed PWM duty cycle
#define DIR_DELAY 1000 // brief delay for abrupt motor changes
#define INTERVAL_MOTOR 2000 // interval for multitasking
#define INTERVAL_SERVO 1000 // interval for multitasking
