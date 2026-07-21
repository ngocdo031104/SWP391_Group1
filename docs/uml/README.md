# 1.2.3 — 1.2.4 Tour Creation / Tour Discovery — PlantUML

## 1. Tour Creation Flow (Swim-lane Activity)

File: `docs/uml/1.2.3_tour_creation_flow.puml`

- 3 lane: **Staff**, **System**, **Admin**
- Step 1–2: Staff tạo và submit tour form
- Step 3–4: Vòng lặp nếu input không hợp lệ
- Step 5: Insert Tour với status = DRAFT
- Step 6: Admin review
- Step 7: Nhánh `(If Publish)` approve/reject

## 2. Tour Discovery Flow (Swim-lane Activity)

File: `docs/uml/1.2.4_tour_discovery_flow.puml`

- 2 lane: **Customer**, **System**
- Step 1–2: Customer search với filter
- Step 3: System query `status = PUBLISHED`
- Step 4 (If No Match) / Step 6 (If Match)
- Step 5: Customer retry nếu no match
- Step 7: Customer view tour detail

## Cách render

```bash
# VSCode: extension "PlantUML" -> Alt+D
plantuml docs/uml/1.2.3_tour_creation_flow.puml
plantuml docs/uml/1.2.4_tour_discovery_flow.puml
```
