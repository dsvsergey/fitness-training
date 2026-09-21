from typing import Any, List, Optional

import anyio
from starlette.requests import Request
from starlette_admin.contrib.sqla import ModelView

from app.crud.machines import remove_machine


class MachineView(ModelView):
    """Deleting a machine used by programs hides it instead of breaking the FK."""

    async def delete(self, request: Request, pks: List[Any]) -> Optional[int]:
        session = request.state.session
        objs = await self.find_by_pks(request, pks)
        for obj in objs:
            await self.before_delete(request, obj)
            await anyio.to_thread.run_sync(remove_machine, session, obj)
        await anyio.to_thread.run_sync(session.commit)
        for obj in objs:
            await self.after_delete(request, obj)
        return len(objs)
