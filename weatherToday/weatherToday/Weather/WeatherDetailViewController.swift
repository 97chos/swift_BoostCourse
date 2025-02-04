//
//  weatherDetailViewController.swift
//  weatherToday
//
//  Created by sangho Cho on 2021/02/17.
//

import Foundation
import UIKit
import SnapKit

class WhetherDetailViewController: UIViewController {

  // MARK: Properties

  private let viewModel: WeatherDetailViewModel!


  // MARK: UI

  private lazy var imgView: UIImageView = {
    let imgView = UIImageView()
    return imgView
  }()
  private lazy var weatherLabel: UILabel = {
    let label = UILabel()
    label.font = .boldSystemFont(ofSize: 20)
    return label
  }()
  private lazy var temperatureLabel: UILabel = {
    let label = UILabel()
    label.text = self.viewModel.city.temperature
    label.font = .systemFont(ofSize: 18)
    label.sizeToFit()
    return label
  }()
  private lazy var rainProbabilityLabel: UILabel = {
    let label = UILabel()
    label.text = self.viewModel.city.rainProbability
    label.font = .systemFont(ofSize: 18)
    label.sizeToFit()
    return label
  }()


  // MARK: Initializing

  init(viewModel: WeatherDetailViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  // MARK: View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.configure()
  }


  // MARK: Congigure

  private func configure() {
    self.viewConfigure()
    self.setWeatherInformation()
    self.layout()
  }

  private func viewConfigure() {
    self.view.backgroundColor = .systemBackground
    self.title = self.viewModel.city.cityName
  }

  private func setWeatherInformation() {
    self.imgView.image = UIImage(named: "\(self.viewModel.weatherInformation().0)")
    self.weatherLabel.text = self.viewModel.weatherInformation().1
  }


  // MARK: Layout

  private func layout() {
    self.view.addSubview(imgView)
    self.view.addSubview(weatherLabel)
    self.view.addSubview(temperatureLabel)
    self.view.addSubview(rainProbabilityLabel)

    self.imgView.snp.makeConstraints{
      $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
      $0.centerX.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.2)
      $0.width.equalTo(self.imgView.snp.height)
    }
    self.weatherLabel.snp.makeConstraints{
      $0.top.equalTo(self.imgView.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
    }
    self.temperatureLabel.snp.makeConstraints{
      $0.top.equalTo(self.weatherLabel.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
    }
    self.rainProbabilityLabel.snp.makeConstraints{
      $0.top.equalTo(self.temperatureLabel.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
    }
  }
}
