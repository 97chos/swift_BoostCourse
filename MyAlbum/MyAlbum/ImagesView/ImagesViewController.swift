//
//  ImagesViewController.swift
//  MyAlbum
//
//  Created by sangho Cho on 2021/02/20.
//

import Foundation
import UIKit
import Photos
import SnapKit

class ImagesViewController: UIViewController {

  // MARK: Properties

  private let assets: PHAssetCollection!
  private var fetchResult: PHFetchResult<PHAsset>!
  private let imageManager: PHCachingImageManager = PHCachingImageManager()
  private var selectedItems: [PHAsset] = [] {
    didSet {
      if self.selectedItems.count < 1 {
        self.shareButton.isEnabled = false
        self.trashButton.isEnabled = false
      } else {
        self.shareButton.isEnabled = true
        self.trashButton.isEnabled = true
      }
    }
  }
  private var descend: Bool = false {
    didSet {
      if descend {
        self.sortButton.title = "오래된순"
      } else {
        self.sortButton.title = "최신순"
      }
    }
  }


  // MARK: UI

  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
    collectionView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    collectionView.backgroundColor = .systemBackground
    collectionView.alwaysBounceVertical = true
    collectionView.isEditing = true
    return collectionView
  }()
  private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .vertical
    flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    flowLayout.minimumLineSpacing = 10
    flowLayout.minimumInteritemSpacing = 10
    return flowLayout
  }()
  private lazy var selectButton: UIBarButtonItem = {
    let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.edit))
    return button
  }()
  private lazy var toolBar: UIToolbar = {
    let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56))
    toolBar.barTintColor = .systemGray5
    return toolBar
  }()
  private lazy var sortButton: UIBarButtonItem = {
    let barbutton = UIBarButtonItem(title: "최신순", style: .plain, target: self, action: #selector(self.chageAlign))
    return barbutton
  }()
  private lazy var shareButton: UIBarButtonItem = {
    let button = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))
    button.isEnabled = false
    return button
  }()
  private lazy var trashButton: UIBarButtonItem = {
    let button = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.trash))
    button.isEnabled = false
    return button
  }()
  private let flexibleSpace1: UIBarButtonItem = {
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    return flexibleSpace
  }()
  private let flexibleSpace2: UIBarButtonItem = {
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
    return flexibleSpace
  }()


  // MARK: Initializing

  init(asset: PHAssetCollection) {
    self.assets = asset
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: View LifeCycle

  override func viewDidLoad() {
    print(self.collectionView.isEditing)
    super.viewDidLoad()
    self.configure()
    PHPhotoLibrary.shared().register(self)
  }


  // MARK: Actions

  @objc private func edit() {
    if self.collectionView.isEditing {
      self.collectionView.isEditing = false
      self.collectionView.allowsMultipleSelection = true
      self.selectButton.title = "취소"
    } else {
      self.collectionView.isEditing = true
      self.collectionView.allowsMultipleSelection = false
      self.selectedItems = []
      self.selectButton.title = "선택"
    }
  }

  @objc private func chageAlign() {
    self.descend = !descend
    self.fetchFromAssetCollection(descend: descend)
    self.collectionView.reloadSections(IndexSet(integer: 0))
  }

  @objc private func share() {
    var selectedImages: [UIImage] = []
    self.selectedItems.forEach { asset in
      self.imageManager.requestImage(for: asset,
                                     targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                     contentMode: .aspectFill,
                                     options: nil,
                                     resultHandler: { image, _ in
                                      guard let image = image else {
                                        return
                                      }
                                      selectedImages.append(image)
                                     })
    }
    let activityVC = UIActivityViewController(activityItems: selectedImages, applicationActivities: nil)
    self.present(activityVC, animated: true)
  }

  @objc private func trash() {
    PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.deleteAssets(self.selectedItems as NSArray)}, completionHandler: nil)
  }


  // MARK: Configuration

  private func configure() {
    self.viewConfigure()
    self.collectionViewConfigure()
    self.fetchFromAssetCollection()
    self.layout()
  }

  private func viewConfigure() {
    self.title = self.assets.localizedTitle
    self.view.backgroundColor = .systemBackground
    self.navigationItem.largeTitleDisplayMode = .never
    self.navigationItem.rightBarButtonItem = self.selectButton
  }

  private func collectionViewConfigure() {
    self.collectionView.delegate = self
    self.collectionView.dataSource = self

    self.collectionView.setCollectionViewLayout(self.collectionViewFlowLayout, animated: true)
    self.collectionView.register(ImagesViewItem.self, forCellWithReuseIdentifier: ReusealbleIdentifier.imagesViewCell)
  }


  // MARK: Fetch Asset

  private func fetchFromAssetCollection(descend: Bool = false) {
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: descend)]
    self.fetchResult = PHAsset.fetchAssets(in: self.assets, options: fetchOptions)
  }


  // MARK: Layout

  private func layout() {
    self.view.addSubview(self.collectionView)
    self.view.addSubview(toolBar)

    self.toolBar.snp.makeConstraints{
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
      $0.width.equalToSuperview()
      $0.leading.equalToSuperview()
    }

    self.toolBar.setItems([shareButton,flexibleSpace1,sortButton,flexibleSpace2,trashButton], animated: true)
  }
}


extension ImagesViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if !selectedItems.contains(self.fetchResult[indexPath.item]) {
      self.selectedItems.append(self.fetchResult[indexPath.item])
    }
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    if selectedItems.contains(self.fetchResult[indexPath.item]) {
      let index = self.selectedItems.firstIndex(of: self.fetchResult[indexPath.item])
      self.selectedItems.remove(at: index ?? 0)
    }
  }
}

extension ImagesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.fetchResult?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: ReusealbleIdentifier.imagesViewCell, for: indexPath) as? ImagesViewItem else { return UICollectionViewCell() }

    let asset = self.fetchResult?.object(at: indexPath.item) ?? PHAsset()

    self.imageManager.requestImage(for: asset,
                                   targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                   contentMode: .aspectFill,
                                   options: nil,
                                   resultHandler: { image, _ in
                                    guard let image = image else {
                                      return
                                    }
                                    item.set(image: image)
                                   })

    return item
  }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let inset = self.collectionViewFlowLayout.sectionInset

    let itemPerRow: CGFloat = 3
    let widthPadding = inset.left * (itemPerRow + 1)

    let widthAndHeight: CGFloat = (self.collectionView.frame.width - widthPadding) / itemPerRow

    return CGSize(width: widthAndHeight, height: widthAndHeight)
  }
}

extension ImagesViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    guard let changes = changeInstance.changeDetails(for: fetchResult) else {
      return
    }

    self.fetchResult = changes.fetchResultAfterChanges

    DispatchQueue.main.async {
      self.collectionView.reloadSections(IndexSet(arrayLiteral: 0))
    }
  }
}
