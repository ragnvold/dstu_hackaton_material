package main

import (
	"context"
	"database/sql"
	"fmt"

	openapi "codeberg.org/shinyzero0/axenix-2024/apis"
	"codeberg.org/shinyzero0/axenix-2024/models"
	"github.com/gofiber/fiber/v2"
	"github.com/samber/lo"
	"github.com/volatiletech/sqlboiler/v4/boil"
	_ "modernc.org/sqlite"
)

func main() {
	fmt.Println(f())
}
func f() error {
	db, err := sql.Open("sqlite", "./database.db")
	if err != nil {
		return err
	}
	ctx := context.Background()
	app := fiber.New()
	api := app
	// api.Get("/route", makeGetRoute(db, ctx))
	api.Get("/points", makeGetPoints(db, ctx))
	// api.Get("/points/:id", makeGetPointHandle(db, ctx))
	// api.Get("/points/:id/data/:id", makeGetPointHandle(db, ctx))
	// api.Get("/points/:id/data/:id", makeGetPointHandle(db, ctx))
	api.Get("/movements", makeGetMovements(db, ctx))
	// api.Post("/import")
	// api.Get("/export")
	return app.Listen(":8080")
}

func makeGetRoute(db boil.ContextExecutor, ctx context.Context) fiber.Handler {
	return func(c *fiber.Ctx) error {
		return c.JSON(5)
	}
}

func makeGetMovements(db boil.ContextExecutor, ctx context.Context) fiber.Handler {
	return func(c *fiber.Ctx) error {
		ts, err := models.Transportations().All(ctx, db)
		if err != nil {
			return err
		}
		return c.JSON(
			lo.Map(
				ts,
				func(item *models.Transportation, _ int) *openapi.TransportationView {
					from, err := item.From().One(ctx, db)
					if err != nil {
						fmt.Printf("err: %v\n", err)
					}
					to, err := item.From().One(ctx, db)
					if err != nil {
						fmt.Printf("err: %v\n", err)
					}
					from_t, err := from.WarehouseType().One(ctx, db)
					if err != nil {
						fmt.Println(err)
					}
					to_t, err := to.WarehouseType().One(ctx, db)
					if err != nil {
						fmt.Println(err)
					}
					tr, err := item.Transport().One(ctx, db)
					if err != nil {
						fmt.Println(err)
					}
					bs, err := item.Batches().All(ctx, db)
					if err != nil {
						fmt.Println(err)
					}
					return openapi.NewTransportationView(
						*openapi.NewTransportView(
							tr.TransportID,
							float32(tr.Volume),
						),
						*openapi.NewPointView(
							[]float32{float32(from.Longitude), float32(from.Latitude)},
							from.Name,
							from_t.Type,
						),
						*openapi.NewPointView(
							[]float32{float32(to.Longitude), float32(to.Latitude)},
							to.Name,
							to_t.Type,
						),
						lo.Map(bs, func(b *models.Batch, _ int) openapi.MovementView {
							p, err := b.Product().One(ctx, db)
							if err != nil {
								// err
							}
							return *openapi.NewMovementView(
								*openapi.NewProductView(p.Name, p.ExpirationTime),
								b.BatchID,
								float32(b.Amount),
							)
						}),
					)
				},
			),
		)
	}
}

func makeGetPointHandle(db boil.ContextExecutor, ctx context.Context) fiber.Handler {
	return func(c *fiber.Ctx) error {
		return c.JSON(0)
	}
}
func makeGetPoints(db boil.ContextExecutor, ctx context.Context) fiber.Handler {
	return func(c *fiber.Ctx) error {
		whs, err := models.Warehouses().All(ctx, db)
		if err != nil {
			return err
		}
		return c.JSON(
			lo.Map(whs, func(item *models.Warehouse, _ int) *openapi.PointView {
				t, err := item.WarehouseType().One(ctx, db)
				if err != nil {
					fmt.Println(err)
				}
				return openapi.NewPointView(
					[]float32{float32(item.Longitude), float32(item.Latitude)},
					item.Name,
					t.Type,
				)
			}),
		)
	}
}
