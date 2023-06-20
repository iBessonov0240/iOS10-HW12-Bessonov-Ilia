//
//  ViewController.swift
//  iOS10-HW12-Bessonov Ilia
//
//  Created by i0240 on 17.06.2023.
//

import UIKit

class ViewController: UIViewController {

    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var startPoint = CGFloat(-Double.pi / 2)
    private var endPoint = CGFloat(3 * Double.pi / 2)
    private var circularViewWorkDuration: TimeInterval = 25
    private var circularViewRestDuration: TimeInterval = 10
    private var timer = Timer()
    private var count = 0.0
    private var isWorkTime = true
    private var isStarted = false
    private var startTime: CFTimeInterval = 0
    private var pausedTime: CFTimeInterval = 0
    private var isFirstTime = true

    // MARK: - Outlets

    private lazy var clockLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00.0"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private lazy var circularProgressBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var startPauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play"), for: .normal)
        button.tintColor = .systemRed
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(startPauseButtonPressed), for: .touchUpInside)
        return button
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        setupHierarchy()
        setupLayout()
        createCircularPath()
    }

    // MARK: - Setup

    private func setupHierarchy() {
        view.addSubviews([circularProgressBarView, clockLabel, startPauseButton])
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            circularProgressBarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circularProgressBarView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            clockLabel.centerXAnchor.constraint(equalTo: circularProgressBarView.centerXAnchor),
            clockLabel.centerYAnchor.constraint(equalTo: circularProgressBarView.centerYAnchor, constant: -20),

            startPauseButton.centerXAnchor.constraint(equalTo: circularProgressBarView.centerXAnchor),
            startPauseButton.centerYAnchor.constraint(equalTo: circularProgressBarView.centerYAnchor, constant: 50),
            startPauseButton.widthAnchor.constraint(equalTo: clockLabel.heightAnchor),
            startPauseButton.heightAnchor.constraint(equalTo: clockLabel.heightAnchor)
        ])
    }

    private func createCircularPath() {
        // create circularPath for circleLater and progressLayer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: circularProgressBarView.frame.size.width / 2.0, y: circularProgressBarView.frame.size.height / 2.0), radius: 120, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        // circleLayer path defined to circularPath
        circleLayer.path = circularPath.cgPath
        // ui edits
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 20.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor.clear.cgColor
        // added circleLayer to layer
        circularProgressBarView.layer.addSublayer(circleLayer)
        // progressLayer path defined to circularPath
        progressLayer.path = circularPath.cgPath
        // ui edits
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        progressLayer.strokeColor = UIColor.systemRed.cgColor
        // added progressLayer to layer
        circularProgressBarView.layer.addSublayer(progressLayer)
    }

    private func progressAnimation(duration: TimeInterval) {
        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1.0
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }

    private func pauseLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    private func resumeLayer(layer: CALayer) {
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

    // MARK: - Actions

    @objc func startPauseButtonPressed() {
        if isStarted {
            // Pause the timer and animation
            isStarted = false
            timer.invalidate()
            startPauseButton.setImage(UIImage(systemName: "play"), for: .normal)
            pauseLayer(layer: progressLayer)
            if !isWorkTime {
                startPauseButton.tintColor = .systemGreen
                clockLabel.textColor = .systemGreen
            } else {
                startPauseButton.tintColor = .systemRed
                clockLabel.textColor = .systemRed
            }
        } else {
            if isFirstTime {
                // start animation
                isStarted = true
                startPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
                startPauseButton.tintColor = .systemRed
                clockLabel.textColor = .systemRed
                progressAnimation(duration: circularViewWorkDuration)
                isFirstTime = false
            } else {
                // resume animation
                isStarted = true
                startPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
                resumeLayer(layer: progressLayer)
                if !isWorkTime {
                    startPauseButton.tintColor = .systemGreen
                    clockLabel.textColor = .systemGreen
                } else {
                    startPauseButton.tintColor = .systemRed
                    clockLabel.textColor = .systemRed
                }
            }

            timer = Timer(timeInterval: 0.1,
                          target: self,
                          selector: #selector(timerCounter),
                          userInfo: nil,
                          repeats: true)
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    @objc func timerCounter() {
        count += 0.1
        let flooredCounter = Int(floor(count))
        let second = (flooredCounter % 3600) % 60
        var secondString = "\(second)"
        if second < 10 {
            secondString = "0\(second)"
        }
        let decisecond = String(format: "%.1f", count).components(separatedBy: ".").last!
        clockLabel.text = "\(secondString).\(decisecond)"

        if !isWorkTime && count >= circularViewRestDuration {
            progressLayer.removeAllAnimations()
            pausedTime = 0.0
            count = 0.0
            isWorkTime = true
            startPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
            startPauseButton.tintColor = .systemRed
            clockLabel.textColor = .systemRed
            progressLayer.strokeColor = UIColor.systemRed.cgColor
            let remainingDuration = circularViewWorkDuration - pausedTime
            progressAnimation(duration: remainingDuration)
        } else if count >= circularViewWorkDuration {
            progressLayer.removeAllAnimations()
            pausedTime = 0.0
            count = 0.0
            isWorkTime = false
            startPauseButton.setImage(UIImage(systemName: "pause"), for: .normal)
            startPauseButton.tintColor = .systemGreen
            clockLabel.textColor = .systemGreen
            progressLayer.strokeColor = UIColor.systemGreen.cgColor
            let remainingDuration = circularViewRestDuration - pausedTime
            progressAnimation(duration: remainingDuration)
        }
    }
}

