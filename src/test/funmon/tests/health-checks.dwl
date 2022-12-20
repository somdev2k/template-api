%dw 2.0
import * from bat::BDD
import * from bat::Assertions
---
suite("Health Checks") in [
    it must "alive and ready" in [
        ["alive", "ready"] map (check) ->
            GET `$(config.url)/$(check)`
            with {
                headers: {
                    "x-correlation-id": "$(config.api)-$(config.env)-$(check)-$(uuid())"
                }
            }
            assert [
                $.response.status            mustEqual 200,
                $.response.payload as String mustEqual "UP"
            ]
    ]
]
