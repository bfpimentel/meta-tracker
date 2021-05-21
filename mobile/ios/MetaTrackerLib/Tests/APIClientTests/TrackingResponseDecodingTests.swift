//
//  File.swift
//
//
//  Created by Guilherme Souza on 21/05/21.
//

import APIClient
import Foundation
import Models
import XCTest

final class TrackingResponseDecodingTests: XCTestCase {

  func testDecoding() throws {
    let data = try XCTUnwrap(json.data(using: .utf8))
    _ = try data.apiDecoded(as: [Tracking].self)
  }
}

let json = """
  [
    {
      "code": "LE251026577SE",
      "isDelivered": true,
      "isTracked": true,
      "postedAt": "2021-05-12T16:36:00.000Z",
      "updatedAt": "2021-05-18T19:41:00.000Z",
      "events": [
        {
          "description": "Objeto postado",
          "trackedAt": "2021-05-12T16:36:00.000Z",
          "country": "SUECIA"
        },
        {
          "description": "Objeto recebido na unidade de exportação no país de origem",
          "trackedAt": "2021-05-12T16:39:00.000Z",
          "country": "SUECIA"
        },
        {
          "description": "Objeto recebido pelos Correios do Brasil",
          "trackedAt": "2021-05-14T18:29:00.000Z",
          "city": "CURITIBA",
          "state": "PR",
          "country": "BRASIL"
        },
        {
          "description": "Fiscalização aduaneira finalizada",
          "trackedAt": "2021-05-14T22:24:00.000Z",
          "city": "CURITIBA",
          "state": "PR",
          "country": "BRASIL"
        },
        {
          "description": "Objeto em trânsito de Unidade de Logística Integrada em CURITIBA / PR para Unidade de Tratamento em CURITIBA / PR",
          "trackedAt": "2021-05-14T22:26:00.000Z",
          "city": "CURITIBA",
          "state": "PR",
          "country": "BRASIL"
        },
        {
          "description": "Objeto em trânsito de Unidade de Tratamento em CURITIBA / PR para Unidade de Distribuição em MARINGA / PR",
          "trackedAt": "2021-05-15T18:53:00.000Z",
          "city": "CURITIBA",
          "state": "PR",
          "country": "BRASIL"
        },
        {
          "description": "Objeto saiu para entrega ao destinatário",
          "trackedAt": "2021-05-18T11:21:00.000Z",
          "city": "MARINGA",
          "state": "PR",
          "country": "BRASIL"
        },
        {
          "description": "Objeto entregue ao destinatário",
          "trackedAt": "2021-05-18T19:41:00.000Z",
          "city": "MARINGA",
          "state": "PR",
          "country": "BRASIL"
        }
      ]
    }
  ]

  """
