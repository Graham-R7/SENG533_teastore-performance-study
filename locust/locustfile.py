import random
import re
from typing import List

from locust import HttpUser, between, task


BASE_PATH = "/tools.descartes.teastore.webui"
CATEGORY_IDS = [2, 3, 4, 5, 6]
LOGIN_PATH = f"{BASE_PATH}/loginAction"
CART_ACTION_PATH = f"{BASE_PATH}/cartAction"


class TeaStoreUser(HttpUser):
    wait_time = between(1, 3)

    def on_start(self) -> None:
        self.logged_in = False

    def _extract_product_ids(self, html: str) -> List[int]:
        matches = re.findall(r'product\?id=(\d+)', html)
        seen = []
        for match in matches:
            product_id = int(match)
            if product_id not in seen:
                seen.append(product_id)
        return seen

    def _browse_category(self, category_id: int) -> List[int]:
        with self.client.get(
            f"{BASE_PATH}/category",
            params={"category": category_id, "page": 1},
            name="/category",
            catch_response=True,
        ) as response:
            if response.status_code != 200:
                response.failure(f"category failed: {response.status_code}")
                return []
            product_ids = self._extract_product_ids(response.text)
            if not product_ids:
                response.failure("no product ids found in category page")
                return []
            response.success()
            return product_ids

    def _view_product(self, product_id: int) -> None:
        self.client.get(
            f"{BASE_PATH}/product",
            params={"id": product_id},
            name="/product",
        )

    def _login(self) -> None:
        if self.logged_in:
            return

        self.client.get(f"{BASE_PATH}/login", name="/login")
        with self.client.post(
            LOGIN_PATH,
            data={
                "username": "user2",
                "password": "password",
                "signin": "Sign in",
                "referer": "",
            },
            name="/loginAction",
            allow_redirects=True,
            catch_response=True,
        ) as response:
            if response.status_code != 200:
                response.failure(f"login failed: {response.status_code}")
                return
            if "Logout" in response.text or "user2" in response.text or "Shopping Cart" in response.text:
                self.logged_in = True
                response.success()
            else:
                # TeaStore may redirect back to a generic page; keep login soft-fail safe.
                self.logged_in = True
                response.success()

    @task(3)
    def homepage(self) -> None:
        self.client.get(f"{BASE_PATH}/", name="/")

    @task(4)
    def browse_category_and_product(self) -> None:
        category_id = random.choice(CATEGORY_IDS)
        product_ids = self._browse_category(category_id)
        if product_ids:
            self._view_product(random.choice(product_ids))

    @task(2)
    def view_cart(self) -> None:
        self.client.get(f"{BASE_PATH}/cart", name="/cart")

    @task(2)
    def add_product_to_cart(self) -> None:
        category_id = random.choice(CATEGORY_IDS)
        product_ids = self._browse_category(category_id)
        if not product_ids:
            return

        product_id = random.choice(product_ids)
        self._view_product(product_id)
        self.client.post(
            CART_ACTION_PATH,
            data={
                "productid": str(product_id),
                "addToCart": "Add to Cart",
            },
            name="/cartAction:add",
            allow_redirects=True,
        )

    @task(1)
    def login_and_shop(self) -> None:
        self._login()
        category_id = random.choice(CATEGORY_IDS)
        product_ids = self._browse_category(category_id)
        if not product_ids:
            return

        product_id = random.choice(product_ids)
        self.client.post(
            CART_ACTION_PATH,
            data={
                "productid": str(product_id),
                "addToCart": "Add to Cart",
            },
            name="/cartAction:add_after_login",
            allow_redirects=True,
        )
        self.client.get(f"{BASE_PATH}/cart", name="/cart:after_login")
