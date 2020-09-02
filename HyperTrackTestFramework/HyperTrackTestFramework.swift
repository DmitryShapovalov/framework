//
//  HyperTrackTestFramework.swift
//  HyperTrackTestFramework
//
//  Created by Dmytro Shapovalov on 02.09.2020.
//

import Foundation

enum SchoolGrades: Comparable {
   case F
   case E
   case D
   case C
   case B
   case A
}

public final class Core {
  public static func printInfo() {
    let info = SchoolGrades.A > SchoolGrades.F
    print("The variable A is bigger from F \(info)")
  }
}
