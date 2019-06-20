# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_05_155538) do

  create_table "checkpoints", force: :cascade do |t|
    t.integer "block_num", null: false
    t.string "block_hash", null: false
    t.datetime "block_timestamp", null: false
    t.string "ref_trx_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contract_deploys", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "name", null: false
    t.string "params", null: false
    t.text "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "name"], name: "contract_deploys-by-trx_id-name"
  end

  create_table "contract_updates", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "name", null: false
    t.string "params", null: false
    t.text "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "name"], name: "contract_updates-by-trx_id-name"
  end

  create_table "market_buys", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.string "price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "market_buys-by-trx_id-symbol"
  end

  create_table "market_cancels", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "action_type", null: false
    t.string "action_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", nil], name: "market_cancels-by-trx_id-symbol"
  end

  create_table "market_sells", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.string "price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "market_sells-by-trx_id-symbol"
  end

  create_table "sscstore_buys", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "recipient", null: false
    t.string "amount_steemsbd", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "recipient"], name: "sscstore_buys-by-trx_id-recipient"
  end

  create_table "steempegged_buys", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "recipient", null: false
    t.string "amount_steemsbd", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "recipient"], name: "steempegged_buys-by-trx_id-recipient"
  end

  create_table "steempegged_remove_withdrawals", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "action_id", null: false
    t.string "recipient", null: false
    t.string "amount_steemsbd", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "recipient"], name: "steempegged_remove_withdrawals-by-trx_id-action_id-recipient"
  end

  create_table "steempegged_withdraws", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens_cancel_unstakes", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "tx_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "tx_id"], name: "tokens_cancel_unstakes-by-trx_id-tx_id"
    t.index ["trx_id"], name: "tokens_cancel_unstakes-by-trx_id"
  end

  create_table "tokens_check_pending_unstakes", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id"], name: "tokens_check_pending_unstakes-by-trx_id"
  end

  create_table "tokens_creates", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "name", null: false
    t.string "url", default: "", null: false
    t.integer "precision", null: false
    t.integer "max_supply", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "tokens_creates-by-symbol", unique: true
    t.index ["trx_id", "symbol"], name: "tokens_creates-by-trx_id-symbol"
  end

  create_table "tokens_delegates", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "to", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "to", "symbol"], name: "tokens_delegates-by-to-symbol"
    t.index ["trx_id"], name: "tokens_delegates-by-trx_id"
  end

  create_table "tokens_enable_delegations", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.integer "undelegation_cooldown", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", nil, "symbol"], name: "tokens_enable_delegations-by-symbol"
    t.index ["trx_id"], name: "tokens_enable_delegations-by-trx_id"
  end

  create_table "tokens_enable_stakings", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.integer "unstaking_cooldown", null: false
    t.integer "number_transactions", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens_issues", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "to", null: false
    t.string "quantity", null: false
    t.string "memo", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol", "to"], name: "tokens_issues-by-trx_id-symbol-to"
    t.index ["trx_id", "symbol"], name: "tokens_issues-by-trx_id-symbol"
  end

  create_table "tokens_stakes", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "tokens_stakes-by-trx_id-symbol"
  end

  create_table "tokens_transfer_ownerships", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "to", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "tokens_transfer_ownerships-by-trx_id-symbol"
  end

  create_table "tokens_transfer_to_contracts", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "to", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "to", "symbol"], name: "tokens_transfer_to_contracts-by-to-symbol"
    t.index ["trx_id"], name: "tokens_transfer_to_contracts-by-trx_id"
  end

  create_table "tokens_transfers", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "to", null: false
    t.string "quantity", null: false
    t.string "memo", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol", "to"], name: "tokens_transfers-by-trx_id-symbol-to"
    t.index ["trx_id", "symbol"], name: "tokens_transfers-by-trx_id-symbol"
  end

  create_table "tokens_undelegates", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "from", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "from", "symbol"], name: "tokens_undelegates-by-from-symbol"
    t.index ["trx_id"], name: "tokens_undelegates-by-trx_id"
  end

  create_table "tokens_unstakes", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.string "quantity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "tokens_unstakes-by-trx_id-symbol"
  end

  create_table "tokens_update_metadata", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.text "metadata", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "tokens_update_metadata-by-trx_id-symbol"
  end

  create_table "tokens_update_params", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.text "token_creation_fee", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tokens_update_precisions", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.integer "precision", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", nil, "symbol"], name: "tokens_update_precisions-by-to-symbol"
    t.index ["trx_id"], name: "tokens_update_precisions-by-trx_id"
  end

  create_table "tokens_update_urls", force: :cascade do |t|
    t.integer "trx_id", null: false
    t.string "symbol", null: false
    t.text "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trx_id", "symbol"], name: "tokens_update_urls-by-trx_id-symbol"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "block_num", null: false
    t.integer "ref_steem_block_num", null: false
    t.string "trx_id", null: false
    t.integer "trx_in_block", null: false
    t.string "sender", null: false
    t.string "contract", null: false
    t.string "action", null: false
    t.text "payload", null: false
    t.string "executed_code_hash", null: false
    t.string "hash", null: false
    t.string "database_hash", null: false
    t.text "logs", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["block_num", "trx_id", "trx_in_block", "sender", "contract", "action", "timestamp"], name: "transactions-by-trx_id-trx_in_block-sender-contract-action-ti"
    t.index ["block_num", "trx_id", "trx_in_block"], name: "transactions-by-block_num-trx_id-trx_in_block", unique: true
    t.index ["database_hash", "trx_id", "trx_in_block"], name: "transactions-by-database_hash-trx_id-trx_in_block", unique: true
    t.index ["hash"], name: "transactions-by-hash", unique: true
    t.index ["trx_id", "trx_in_block"], name: "transactions-by-trx_id-trx_in_block"
    t.index ["trx_in_block", "timestamp"], name: "transactions-by-trx_in_block-timestamp"
  end

end
