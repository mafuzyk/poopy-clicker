import sys
import json
import os
import random

from PyQt6.QtWidgets import (
    QApplication, QWidget, QPushButton, QLabel, QDialog,
    QVBoxLayout, QHBoxLayout, QSizePolicy
)
from PyQt6.QtCore import QTimer, Qt, QPropertyAnimation, QRect, QEasingCurve
from PyQt6.QtGui import QFont, QMovie, QTransform


def get_base_path():
    if getattr(sys, "frozen", False):
        return sys._MEIPASS if hasattr(sys, "_MEIPASS") else os.path.dirname(sys.executable)
    return os.path.dirname(os.path.abspath(__file__))


BASE_PATH = get_base_path()
ASSET_PATH = os.path.join(BASE_PATH, "assets")
SAVE_PATH = os.path.join(BASE_PATH, "save.json")

MAX_GOOBERS = 15
CLICK_SPAWN_THRESHOLD = 15
PASSIVE_SPAWN_INTERVAL_MS = 10000
SECRET_SHOP_UNLOCK_CLICKS = 40


def format_number(n):
    suffixes = ["", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
    i = 0
    n = float(n)

    while n >= 1000 and i < len(suffixes) - 1:
        n /= 1000
        i += 1

    if i == 0:
        return str(int(n))

    text = f"{n:.1f}".rstrip("0").rstrip(".")
    return f"{text}{suffixes[i]}"


count = 0
upgrade_level = 0
auto_level = 0

goober_clicks_total = 0
goober_coins = 0
secret_shop_unlocked = False

goober_charm_bought = False
heavy_button_bought = False
lucky_paws_bought = False
sneaky_profit_bought = False
panic_shield_bought = False


class PlayArea(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setMinimumHeight(280)
        self.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Expanding)


class Goober(QLabel):
    def __init__(self, parent, game):
        super().__init__(parent)

        self.game = game
        self.anim_refs = []
        self.state = "walk"
        self.push_cooldown = 0

        self.base_size = 96
        self.facing_left = False

        self.idle_movie = QMovie(os.path.join(ASSET_PATH, "Goober_idle.gif"))
        self.walk_movie = QMovie(os.path.join(ASSET_PATH, "Goober_run.gif"))
        self.scare_movie = QMovie(os.path.join(ASSET_PATH, "Goober_scare.gif"))
        self.panic_movie = QMovie(os.path.join(ASSET_PATH, "Goober_run_scare.gif"))

        self.current_movie = None

        self.vx = random.choice([-1, 1]) * random.randint(1, 2)
        self.vy = random.choice([-1, 1]) * random.randint(1, 2)

        self.idle_movie.frameChanged.connect(self.refresh_current_frame)
        self.walk_movie.frameChanged.connect(self.refresh_current_frame)
        self.scare_movie.frameChanged.connect(self.refresh_current_frame)
        self.panic_movie.frameChanged.connect(self.refresh_current_frame)

        self.update_scale()
        self.set_movie(self.walk_movie)
        self.reset_position(initial=True)

        self.move_timer = QTimer(self)
        self.move_timer.timeout.connect(self.update_movement)
        self.move_timer.start(30)

        self.behavior_timer = QTimer(self)
        self.behavior_timer.timeout.connect(self.random_behavior)
        self.behavior_timer.start(random.randint(1800, 2600))

    def update_scale(self):
        area_h = max(280, self.parent().height())
        self.base_size = max(72, min(int(area_h * 0.22), 140))

        if self.state == "idle":
            self.resize(self.base_size, int(self.base_size * 1.08))
        else:
            self.resize(self.base_size, self.base_size)

        self.refresh_current_frame()

    def refresh_current_frame(self):
        if self.current_movie is None:
            return

        pixmap = self.current_movie.currentPixmap()
        if pixmap.isNull():
            return

        scaled = pixmap.scaled(
            self.size(),
            Qt.AspectRatioMode.KeepAspectRatio,
            Qt.TransformationMode.SmoothTransformation
        )

        if self.facing_left:
            scaled = scaled.transformed(QTransform().scale(-1, 1))

        self.setPixmap(scaled)

    def update_facing(self):
        self.facing_left = self.vx < 0
        self.refresh_current_frame()

    def set_movie(self, movie):
        self.current_movie = movie
        movie.start()
        movie.jumpToFrame(0)
        self.refresh_current_frame()

    def reset_position(self, initial=False):
        self.state = "walk"
        self.vx = random.choice([-1, 1]) * random.randint(1, 2)
        self.vy = random.choice([-1, 1]) * random.randint(1, 2)
        self.update_facing()
        self.push_cooldown = 0

        self.update_scale()
        self.set_movie(self.walk_movie)

        max_x = max(0, self.parent().width() - self.width())
        max_y = max(0, self.parent().height() - self.height())

        self.move(
            random.randint(0, max_x),
            random.randint(0, max_y)
        )

        if not initial:
            self.show()

    def random_behavior(self):
        global goober_charm_bought

        if self.state != "walk":
            return

        idle_chance = 0.25
        if goober_charm_bought:
            idle_chance = 0.12

        if random.random() < idle_chance:
            self.state = "idle"
            self.update_scale()
            self.set_movie(self.idle_movie)
            QTimer.singleShot(random.randint(700, 1400), self.resume_walk)

    def resume_walk(self):
        if self.state == "idle":
            self.state = "walk"
            self.update_scale()
            self.set_movie(self.walk_movie)

    def update_movement(self):
        if self.push_cooldown > 0:
            self.push_cooldown -= 1

        if self.state in ["walk", "panic"]:
            self.move(self.x() + self.vx, self.y() + self.vy)

        if self.state != "panic":
            bounced = False

            if self.x() <= 0 or self.x() >= self.parent().width() - self.width():
                self.vx *= -1
                bounced = True

            if self.y() <= 0 or self.y() >= self.parent().height() - self.height():
                self.vy *= -1
                bounced = True

            if bounced:
                self.update_facing()
        else:
            if self.x() > self.parent().width() + 60 or self.x() < -self.width() - 60:
                self.hide()

        self.push_click_button()

    def push_click_button(self):
        global heavy_button_bought, panic_shield_bought

        if self.push_cooldown > 0:
            return

        btn = self.game.click_btn
        if not self.geometry().intersects(btn.geometry()):
            return

        if self.state == "panic":
            push_multiplier = 28
            if panic_shield_bought:
                push_multiplier = 18
        else:
            push_multiplier = 6
            if heavy_button_bought:
                push_multiplier = 3

        push_x = int(self.vx * push_multiplier)
        push_y = int(self.vy * push_multiplier)

        area = self.parent()
        new_x = btn.x() + push_x
        new_y = btn.y() + push_y

        max_x = max(0, area.width() - btn.width())
        max_y = max(0, area.height() - btn.height())

        new_x = max(0, min(new_x, max_x))
        new_y = max(0, min(new_y, max_y))

        btn.move(new_x, new_y)
        self.push_cooldown = 8

    def do_jump(self):
        start_rect = self.geometry()
        jump_height = int(self.height() * 0.2)

        top_rect = QRect(
            start_rect.x(),
            max(0, start_rect.y() - jump_height),
            start_rect.width(),
            start_rect.height()
        )

        anim = QPropertyAnimation(self, b"geometry", self)
        anim.setDuration(200)
        anim.setStartValue(start_rect)
        anim.setKeyValueAt(0.45, top_rect)
        anim.setEndValue(start_rect)
        anim.setEasingCurve(QEasingCurve.Type.OutQuad)

        self.anim_refs.append(anim)
        anim.finished.connect(lambda: self.anim_refs.remove(anim) if anim in self.anim_refs else None)
        anim.start()

    def mousePressEvent(self, event):
        global goober_clicks_total, goober_coins, secret_shop_unlocked, lucky_paws_bought

        if self.state in ["scare", "panic"]:
            return

        goober_clicks_total += 1

        if not secret_shop_unlocked and goober_clicks_total >= SECRET_SHOP_UNLOCK_CLICKS:
            secret_shop_unlocked = True
            self.game.update_secret_shop_button()

        if secret_shop_unlocked:
            gain = 2 if lucky_paws_bought else 1
            goober_coins += gain

        self.game.update_ui()

        self.state = "scare"
        self.update_scale()
        self.set_movie(self.scare_movie)
        self.do_jump()
        QTimer.singleShot(260, self.start_panic)

    def start_panic(self):
        if self.state != "scare":
            return

        self.state = "panic"
        self.update_scale()
        self.set_movie(self.panic_movie)

        direction = 1 if self.x() < self.parent().width() // 2 else -1
        self.vx = direction * random.randint(6, 8)
        self.vy = random.randint(-1, 1)
        self.update_facing()

    def keep_inside_after_resize(self):
        self.update_scale()

        if self.state == "panic":
            return

        max_x = max(0, self.parent().width() - self.width())
        max_y = max(0, self.parent().height() - self.height())

        x = min(max(0, self.x()), max_x)
        y = min(max(0, self.y()), max_y)
        self.move(x, y)


class Game(QWidget):
    def __init__(self):
        super().__init__()

        self.shop = None
        self.secret_shop = None
        self.upgrade_btn = None
        self.auto_btn = None
        self.secret_info_label = None
        self.secret_desc_label = None
        self.secret_buttons = {}
        self.goobers = []
        self.click_spawn_counter = 0

        self.setWindowTitle("poopy clicker")
        self.resize(560, 460)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(18, 18, 18, 18)
        main_layout.setSpacing(14)

        label_font = QFont()
        label_font.setPointSize(14)

        button_font = QFont()
        button_font.setPointSize(11)

        self.label = QLabel()
        self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.label.setFont(label_font)
        main_layout.addWidget(self.label)

        self.auto_label = QLabel()
        self.auto_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.auto_label.setFont(label_font)
        main_layout.addWidget(self.auto_label)

        self.goober_label = QLabel()
        self.goober_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.goober_label.setFont(button_font)
        main_layout.addWidget(self.goober_label)

        self.play_area = PlayArea(self)
        main_layout.addWidget(self.play_area, 1)

        self.click_btn = QPushButton("click", self.play_area)
        self.click_btn.resize(110, 48)
        self.click_btn.setFont(button_font)
        self.click_btn.clicked.connect(self.click)
        self.click_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)

        bottom_row = QHBoxLayout()
        bottom_row.setSpacing(12)

        self.save_btn = QPushButton("save/load")
        self.save_btn.setMinimumHeight(40)
        self.save_btn.setFont(button_font)
        self.save_btn.clicked.connect(self.open_save_dialog)
        self.save_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        bottom_row.addWidget(self.save_btn)

        self.shop_btn = QPushButton("loja")
        self.shop_btn.setMinimumHeight(40)
        self.shop_btn.setFont(button_font)
        self.shop_btn.clicked.connect(self.open_shop)
        self.shop_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        bottom_row.addWidget(self.shop_btn)

        self.secret_shop_btn = QPushButton("loja goobers")
        self.secret_shop_btn.setMinimumHeight(40)
        self.secret_shop_btn.setFont(button_font)
        self.secret_shop_btn.clicked.connect(self.open_secret_shop)
        self.secret_shop_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        self.secret_shop_btn.hide()
        bottom_row.addWidget(self.secret_shop_btn)

        main_layout.addLayout(bottom_row)

        self.timer = QTimer()
        self.timer.timeout.connect(self.auto_loop)
        self.timer.start(1000)

        self.spawn_timer = QTimer()
        self.spawn_timer.timeout.connect(self.try_spawn_goober)
        self.spawn_timer.start(PASSIVE_SPAWN_INTERVAL_MS)

        self.refresh_all()
        QTimer.singleShot(0, self.center_click_button)

    def keyPressEvent(self, event):
        if event.key() in (Qt.Key.Key_Space, Qt.Key.Key_Return, Qt.Key.Key_Enter):
            event.ignore()
            return
        super().keyPressEvent(event)

    def resizeEvent(self, event):
        super().resizeEvent(event)
        self.keep_click_button_inside()

        for goober in self.goobers:
            if goober.isVisible():
                goober.keep_inside_after_resize()

    def get_click_value(self):
        return 2 ** upgrade_level

    def get_auto_value(self):
        global sneaky_profit_bought
        base = 0 if auto_level == 0 else 2 ** (auto_level - 1)
        if sneaky_profit_bought:
            base = int(base * 1.25)
        return base

    def get_click_upgrade_cost(self):
        return 200 * (2 ** upgrade_level)

    def get_auto_upgrade_cost(self):
        return 500 * (2 ** auto_level)

    def get_difficulty_step(self):
        total_upgrades = upgrade_level + auto_level
        return min(28 + (total_upgrades * 3), 120)

    def refresh_all(self):
        self.update_ui()
        self.update_shop_buttons()
        self.update_secret_shop_button()

    def update_ui(self):
        global secret_shop_unlocked, goober_coins

        self.label.setText(f"voce tem ${format_number(count)}!")
        self.auto_label.setText(f"{format_number(self.get_auto_value())}/s")

        if secret_shop_unlocked:
            self.goober_label.setText(f"goober coins: {format_number(goober_coins)}")
        else:
            self.goober_label.setText("")

        if self.secret_info_label is not None:
            self.secret_info_label.setText(f"goober coins: {format_number(goober_coins)}")

        if self.secret_desc_label is not None:
            self.secret_desc_label.setText(
                "Goober Charm: goobers param menos\n"
                "Heavy Button: empurrao normal reduzido\n"
                "Lucky Paws: +1 moeda extra por goober\n"
                "Sneaky Profit: +25% no auto click\n"
                "Panic Shield: empurrao de panico reduzido"
            )

        self.update_secret_shop_buttons()

    def update_secret_shop_button(self):
        global secret_shop_unlocked
        if secret_shop_unlocked:
            self.secret_shop_btn.show()
        else:
            self.secret_shop_btn.hide()

    def center_click_button(self):
        area_w = self.play_area.width()
        area_h = self.play_area.height()
        btn_w = self.click_btn.width()
        btn_h = self.click_btn.height()

        x = max(12, (area_w - btn_w) // 2)
        y = max(12, (area_h - btn_h) // 2)
        self.click_btn.move(x, y)

    def keep_click_button_inside(self):
        area_w = self.play_area.width()
        area_h = self.play_area.height()
        btn_w = self.click_btn.width()
        btn_h = self.click_btn.height()

        max_x = max(12, area_w - btn_w - 12)
        max_y = max(12, area_h - btn_h - 12)

        x = min(max(12, self.click_btn.x()), max_x)
        y = min(max(12, self.click_btn.y()), max_y)
        self.click_btn.move(x, y)

    def move_click_button_randomly(self):
        step = self.get_difficulty_step()

        current_x = self.click_btn.x()
        current_y = self.click_btn.y()

        # movimento um pouco mais "vivo" e menos teleporte seco
        drift_x = random.randint(-step, step)
        drift_y = random.randint(-step // 2, step // 2)

        if random.random() < 0.35:
            drift_x += random.choice([-1, 1]) * (step // 2)

        new_x = current_x + drift_x
        new_y = current_y + drift_y

        area_w = self.play_area.width()
        area_h = self.play_area.height()

        margin = 12
        min_x = margin
        max_x = max(margin, area_w - self.click_btn.width() - margin)
        min_y = margin
        max_y = max(margin, area_h - self.click_btn.height() - margin)

        new_x = max(min_x, min(new_x, max_x))
        new_y = max(min_y, min(new_y, max_y))

        self.click_btn.move(new_x, new_y)

    def try_spawn_goober(self):
        alive_or_visible = sum(1 for g in self.goobers if g.isVisible())
        if alive_or_visible >= MAX_GOOBERS:
            return

        goober = Goober(self.play_area, self)
        goober.show()
        self.goobers.append(goober)

    def click(self):
        global count
        count += self.get_click_value()
        self.update_ui()
        self.move_click_button_randomly()

        self.click_spawn_counter += 1
        if self.click_spawn_counter >= CLICK_SPAWN_THRESHOLD:
            self.click_spawn_counter = 0
            self.try_spawn_goober()

    def auto_loop(self):
        global count
        count += self.get_auto_value()
        self.update_ui()

    def open_shop(self):
        if self.shop is not None and self.shop.isVisible():
            self.shop.raise_()
            self.shop.activateWindow()
            self.update_shop_buttons()
            return

        self.shop = QDialog(self)
        self.shop.setWindowTitle("Loja")
        self.shop.resize(380, 160)

        layout = QVBoxLayout(self.shop)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        shop_font = QFont()
        shop_font.setPointSize(11)

        self.upgrade_btn = QPushButton()
        self.upgrade_btn.setMinimumHeight(44)
        self.upgrade_btn.setFont(shop_font)
        self.upgrade_btn.clicked.connect(self.buy_upgrade)
        self.upgrade_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        layout.addWidget(self.upgrade_btn)

        self.auto_btn = QPushButton()
        self.auto_btn.setMinimumHeight(44)
        self.auto_btn.setFont(shop_font)
        self.auto_btn.clicked.connect(self.buy_auto)
        self.auto_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        layout.addWidget(self.auto_btn)

        self.update_shop_buttons()
        self.shop.show()

    def update_shop_buttons(self):
        if self.upgrade_btn is not None:
            next_click_value = 2 ** (upgrade_level + 1)
            click_cost = self.get_click_upgrade_cost()
            self.upgrade_btn.setText(
                f"upgrade de click | {format_number(next_click_value)}x | ${format_number(click_cost)}"
            )

        if self.auto_btn is not None:
            next_auto_value = 2 ** auto_level
            auto_cost = self.get_auto_upgrade_cost()
            self.auto_btn.setText(
                f"auto click | {format_number(next_auto_value)}/s | ${format_number(auto_cost)}"
            )

    def buy_upgrade(self):
        global count, upgrade_level
        cost = self.get_click_upgrade_cost()

        if count >= cost:
            count -= cost
            upgrade_level += 1
            self.refresh_all()

    def buy_auto(self):
        global count, auto_level
        cost = self.get_auto_upgrade_cost()

        if count >= cost:
            count -= cost
            auto_level += 1
            self.refresh_all()

    def open_secret_shop(self):
        global secret_shop_unlocked

        if not secret_shop_unlocked:
            return

        if self.secret_shop is not None and self.secret_shop.isVisible():
            self.secret_shop.raise_()
            self.secret_shop.activateWindow()
            self.update_ui()
            return

        self.secret_shop = QDialog(self)
        self.secret_shop.setWindowTitle("Loja goobers")
        self.secret_shop.resize(440, 380)

        layout = QVBoxLayout(self.secret_shop)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(10)

        self.secret_info_label = QLabel()
        self.secret_info_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(self.secret_info_label)

        self.secret_desc_label = QLabel()
        self.secret_desc_label.setAlignment(Qt.AlignmentFlag.AlignLeft)
        layout.addWidget(self.secret_desc_label)

        items = [
            ("Goober Charm - 8", self.buy_goober_charm),
            ("Heavy Button - 12", self.buy_heavy_button),
            ("Lucky Paws - 15", self.buy_lucky_paws),
            ("Sneaky Profit - 20", self.buy_sneaky_profit),
            ("Panic Shield - 18", self.buy_panic_shield),
        ]

        self.secret_buttons = {}
        for text, handler in items:
            btn = QPushButton(text)
            btn.clicked.connect(handler)
            layout.addWidget(btn)
            self.secret_buttons[text] = btn

        self.update_ui()
        self.secret_shop.show()

    def update_secret_shop_buttons(self):
        if not self.secret_buttons:
            return

        self.secret_buttons["Goober Charm - 8"].setEnabled(not goober_charm_bought and goober_coins >= 8)
        self.secret_buttons["Heavy Button - 12"].setEnabled(not heavy_button_bought and goober_coins >= 12)
        self.secret_buttons["Lucky Paws - 15"].setEnabled(not lucky_paws_bought and goober_coins >= 15)
        self.secret_buttons["Sneaky Profit - 20"].setEnabled(not sneaky_profit_bought and goober_coins >= 20)
        self.secret_buttons["Panic Shield - 18"].setEnabled(not panic_shield_bought and goober_coins >= 18)

        if goober_charm_bought:
            self.secret_buttons["Goober Charm - 8"].setText("Goober Charm - comprado")
        if heavy_button_bought:
            self.secret_buttons["Heavy Button - 12"].setText("Heavy Button - comprado")
        if lucky_paws_bought:
            self.secret_buttons["Lucky Paws - 15"].setText("Lucky Paws - comprado")
        if sneaky_profit_bought:
            self.secret_buttons["Sneaky Profit - 20"].setText("Sneaky Profit - comprado")
        if panic_shield_bought:
            self.secret_buttons["Panic Shield - 18"].setText("Panic Shield - comprado")

    def buy_goober_charm(self):
        global goober_coins, goober_charm_bought
        if not goober_charm_bought and goober_coins >= 8:
            goober_coins -= 8
            goober_charm_bought = True
            self.update_ui()

    def buy_heavy_button(self):
        global goober_coins, heavy_button_bought
        if not heavy_button_bought and goober_coins >= 12:
            goober_coins -= 12
            heavy_button_bought = True
            self.update_ui()

    def buy_lucky_paws(self):
        global goober_coins, lucky_paws_bought
        if not lucky_paws_bought and goober_coins >= 15:
            goober_coins -= 15
            lucky_paws_bought = True
            self.update_ui()

    def buy_sneaky_profit(self):
        global goober_coins, sneaky_profit_bought
        if not sneaky_profit_bought and goober_coins >= 20:
            goober_coins -= 20
            sneaky_profit_bought = True
            self.update_ui()

    def buy_panic_shield(self):
        global goober_coins, panic_shield_bought
        if not panic_shield_bought and goober_coins >= 18:
            goober_coins -= 18
            panic_shield_bought = True
            self.update_ui()

    def open_save_dialog(self):
        dialog = QDialog(self)
        dialog.setWindowTitle("save/load")
        dialog.resize(260, 100)

        layout = QHBoxLayout(dialog)
        layout.setContentsMargins(16, 16, 16, 16)
        layout.setSpacing(12)

        dialog_font = QFont()
        dialog_font.setPointSize(11)

        save_btn = QPushButton("save")
        save_btn.setMinimumHeight(42)
        save_btn.setFont(dialog_font)
        save_btn.clicked.connect(self.save)
        save_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        layout.addWidget(save_btn)

        load_btn = QPushButton("load")
        load_btn.setMinimumHeight(42)
        load_btn.setFont(dialog_font)
        load_btn.clicked.connect(self.load)
        load_btn.setFocusPolicy(Qt.FocusPolicy.NoFocus)
        layout.addWidget(load_btn)

        dialog.exec()

    def save(self):
        data = {
            "count": count,
            "upgrade_level": upgrade_level,
            "auto_level": auto_level,
            "goober_clicks_total": goober_clicks_total,
            "goober_coins": goober_coins,
            "secret_shop_unlocked": secret_shop_unlocked,
            "goober_charm_bought": goober_charm_bought,
            "heavy_button_bought": heavy_button_bought,
            "lucky_paws_bought": lucky_paws_bought,
            "sneaky_profit_bought": sneaky_profit_bought,
            "panic_shield_bought": panic_shield_bought
        }
        with open(SAVE_PATH, "w", encoding="utf-8") as f:
            json.dump(data, f)

    def load(self):
        global count, upgrade_level, auto_level
        global goober_clicks_total, goober_coins, secret_shop_unlocked
        global goober_charm_bought, heavy_button_bought, lucky_paws_bought
        global sneaky_profit_bought, panic_shield_bought

        if not os.path.exists(SAVE_PATH):
            return

        with open(SAVE_PATH, "r", encoding="utf-8") as f:
            data = json.load(f)

        count = data.get("count", 0)
        upgrade_level = data.get("upgrade_level", 0)
        auto_level = data.get("auto_level", 0)
        goober_clicks_total = data.get("goober_clicks_total", 0)
        goober_coins = data.get("goober_coins", 0)
        secret_shop_unlocked = data.get("secret_shop_unlocked", False)
        goober_charm_bought = data.get("goober_charm_bought", False)
        heavy_button_bought = data.get("heavy_button_bought", False)
        lucky_paws_bought = data.get("lucky_paws_bought", False)
        sneaky_profit_bought = data.get("sneaky_profit_bought", False)
        panic_shield_bought = data.get("panic_shield_bought", False)

        self.refresh_all()


app = QApplication(sys.argv)
window = Game()
window.show()
sys.exit(app.exec())
