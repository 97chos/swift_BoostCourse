//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by sangho Cho on 2021/01/03.
//  Copyright © 2021 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {

    lazy var menuObservable = BehaviorSubject<[Menu]>(value: [])

    lazy var itemsCount = menuObservable.map {
        $0.map{ $0.count }.reduce(0, +)
    }

    lazy var totalPrice = menuObservable.map {
        $0.map{ $0.price * $0.count }.reduce(0, +)
    }


    init() {
        var menus: [Menu] = [
            Menu(id: 0, name: "튀김1", price: 100, count: 0),
            Menu(id: 1, name: "튀김2", price: 100, count: 0),
            Menu(id: 2, name: "튀김3", price: 100, count: 0),
            Menu(id: 3, name: "튀김4", price: 100, count: 0)
        ]

        menuObservable.onNext(menus)
    }

    func clearAllItemSecletions() {
        menuObservable.map { menus in
            menus.map { m in
                Menu(id: m.id, name: m.name, price: m.price, count: 0)
            }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.onNext($0)
        })
    }

    func changeCount(item: Menu, increase: Int) {
        menuObservable.map { menus in
            menus.map { m in
                if m.id == item.id {
                    return Menu(id: m.id, name: m.name, price: m.price, count: m.count + increase)
                } else {
                    return Menu(id: m.id, name: m.name, price: m.price, count: m.count)
                }
            }
        }
        .take(1)
        .subscribe(onNext: {
            self.menuObservable.onNext($0)
        })
    }
}
