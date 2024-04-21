import { api, endpoint, headers, pathParams, request, response, body, Int64 } from "@airtasker/spot";

@api({
	name: "axenix 2024"
})
class Api { }

/**
 * get a list of points
 *
 */
@endpoint({
	method: "GET",
	path: "/points/"
})
class ListPoints {
	@response({ status: 200 }) successResponse(@body body: Array<PointView>) { }
}

/**
 * get a list of movements
 *
 */
@endpoint({
	method: "GET",
	path: "/movements/"
})
class ListMovements {
	@response({ status: 200 }) successResponse(@body body: Array<TransportationView>) { }
}

/**
 * get a list of sales
 *
 */
@endpoint({
	method: "GET",
	path: "/sales/"
})
class ListSales {
	@response({ status: 200 }) successResponse(@body body: Array<SaleView>) { }
}

/**
 * unix epoch (seconds since 1970 for timestamp or just seconds for time period)
 *
 */
type UnixTime = Int64
type Type = {
	value: string
	id: Int64,
}
type DataView = {
	labels: Array<string>,
	data: Array<Dataset>,
}
type Dataset = {
	label: string,
	data: Array<Int64>
}
type PointView = {
	coords: Array<number>,
	name: string,
	type: string
}
type TransportView = {
	id: Int64,
	volume: number
}
type ProductView = {
	name: string,
	expiration_time: Int64,
}
type MovementView = {
	product: ProductView,
	batch: Int64,
	amount: number
}
type TransportationView = {
	transport: TransportView,
	from: PointView,
	to: PointView,
	movements: Array<MovementView>,
}
type SaleView = {
	amount: number,
	batch: Int64,
	price: number,
}
